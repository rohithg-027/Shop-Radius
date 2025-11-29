import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart' hide Order;
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../core/constants.dart';
import '../models/category.dart';
import '../models/vendor.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/service.dart';
import '../providers/cart_provider.dart';

class ApiService {
  static bool useMock = false; // Set to false to use the live Firebase backend

  final _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = fb_auth.FirebaseAuth.instance;
  // --- Cloudinary Configuration ---
  static const String _cloudinaryCloudName = "dq54lttbt"; // <-- IMPORTANT: REPLACE WITH YOUR CLOUD NAME
  static const String _cloudinaryUploadPreset = "shop_radius_unsigned"; // <-- IMPORTANT: REPLACE WITH YOUR PRESET NAME

  final Dio _dio = Dio(); // Kept for Cloudinary uploads

  // ------------------ AUTH ---------------------- //
  Future<Map<String, dynamic>> signup(Map<String, dynamic> body) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(email: body['email'], password: body['password']);
      final user = cred.user;
      if (user == null) throw Exception("Signup failed: No user created.");

      await _firestore.collection('users').doc(user.uid).set({
        'name': body['name'],
        'shopName': body['shopName'],
        'email': body['email'],
        'phone': body['phone'],
        'role': body['role'],
        'businessType': body['businessType'],
        'address': body['address'],
      });

      return {'user': {...(await _firestore.collection('users').doc(user.uid).get()).data()!, 'id': user.uid}, 'token': await user.getIdToken()};
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception('An unknown error occurred during signup.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred during signup.');
    }
  }

  // ------------------ WISHLIST ---------------------- //
  Future<List<String>> getWishlist(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('wishlist')) {
      return List<String>.from(doc.data()!['wishlist']);
    }
    return [];
  }

  Future<void> updateWishlist(String userId, List<String> wishlist) async {
    await _firestore.collection('users').doc(userId).update({'wishlist': wishlist});
  }


  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    try {
      // Find user by email first to check their role before full authentication.
      final userQuery = await _firestore.collection('users').where('email', isEqualTo: body['identifier']).limit(1).get();

      if (userQuery.docs.isEmpty) {
        throw Exception("No user found for that email. Please check the email or sign up.");
      }

      final userDoc = userQuery.docs.first;
      final storedRole = userDoc.data()['role'];
      final attemptedRole = body['role'];

      if (storedRole != attemptedRole) {
        throw Exception("This is a '$storedRole' account. Please log in from the '$storedRole' portal.");
      }

      final cred = await _firebaseAuth.signInWithEmailAndPassword(email: body['identifier'], password: body['password']);
      final user = cred.user;
      if (user == null) throw Exception("Login failed: User not found.");

      return {'user': {...userDoc.data()!, 'id': user.uid}, 'token': await user.getIdToken()};
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // ------------------ PRODUCTS ---------------------- //
  Future<List<dynamic>> getProducts({String? vendorId, String? category}) async {
    Query query = _firestore.collection('products');
    if (vendorId != null) {
      query = query.where('vendorId', isEqualTo: vendorId);
    }
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => <String, dynamic>{'id': doc.id, ...(doc.data() as Map<String, dynamic>? ?? {})}).toList();
  }

  Future<List<Product>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    // Firestore 'in' queries are limited to 30 items.
    // For a production app, you might need to batch this for larger carts.
    final snapshot = await _firestore.collection('products').where(FieldPath.documentId, whereIn: ids).get();
    return snapshot.docs.map((doc) => Product.fromJson({'id': doc.id, ...doc.data()})).toList();
  }


  Future<dynamic> createProduct(Map<String, dynamic> body, String token) async {
    final productId = body.remove('id');
    final vendorId = _firebaseAuth.currentUser?.uid;
    if (vendorId == null) throw Exception("You must be logged in as a vendor.");

    // Fetch vendor's details to embed in the product
    final vendorDoc = await _firestore.collection('users').doc(vendorId).get();
    final shopName = vendorDoc.data()?['shopName'] ?? 'Unnamed Shop';

    final productData = {
      ...body,
      'vendorId': vendorId,
      // Ensure the name_lowercase field is always present and correct
      'name_lowercase': (body['name'] as String?)?.toLowerCase() ?? '',
      // Ensure the category field is present, even if it's a default value
      'category': body['category'] ?? 'General',
      // Ensure the shop data is always embedded correctly
      'shop': {
        'id': vendorId,
        'name': shopName,
      }
    };

    if (productId != null) {
      await _firestore.collection('products').doc(productId).update(productData);
      return {'id': productId, ...productData};
    } else {
      final docRef = await _firestore.collection('products').add({...productData, 'createdAt': FieldValue.serverTimestamp()});
      return {'id': docRef.id, ...productData};
    }
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // ------------------ SERVICES ---------------------- //
  Future<List<dynamic>> getCategories(String type) async {
    final snapshot = await _firestore.collection('categories').where('type', isEqualTo: type).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...(doc.data() as Map<String, dynamic>? ?? {})}).toList();
  }

  Future<List<dynamic>> searchProducts(String query) async {
    final snapshot = await _firestore.collection('products')
      .where('name_lowercase', isGreaterThanOrEqualTo: query.toLowerCase())
      .where('name_lowercase', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
      .limit(20)
      .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<List<Vendor>> getVendors() async {
    final snapshot = await _firestore.collection('users').where('role', isEqualTo: 'vendor').get();
    return snapshot.docs.map((doc) => Vendor.fromJson(doc.id, doc.data() as Map<String, dynamic>? ?? {})).toList();
  }

  Future<List<dynamic>> getServices({String? vendorId}) async {
    Query query = _firestore.collection('services');
    if (vendorId != null) {
      query = query.where('vendorId', isEqualTo: vendorId);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => <String, dynamic>{'id': doc.id, ...(doc.data() as Map<String, dynamic>? ?? {})}).toList();
  }


  Future<dynamic> createService(Map<String, dynamic> body) async {
    final serviceId = body.remove('id');
    final serviceData = {...body, 'vendorId': _firebaseAuth.currentUser?.uid};

    if (serviceId != null) {
      await _firestore.collection('services').doc(serviceId).update(serviceData);
      return {'id': serviceId, ...serviceData};
    } else {
      final docRef = await _firestore.collection('services').add({...serviceData, 'createdAt': FieldValue.serverTimestamp()});
      return {'id': docRef.id, ...serviceData};
    }
  }

  Future<List<dynamic>> getHotDeals() async {
    final snapshot = await _firestore.collection('products').where('isHotDeal', isEqualTo: true).limit(10).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...(doc.data() as Map<String, dynamic>? ?? {})}).toList();
  }

  Future<String> uploadImage(File imageFile, String path) async {
    final url = "https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload";
    final fileName = imageFile.path.split('/').last;
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      'upload_preset': _cloudinaryUploadPreset,
    });
    
    final response = await _dio.post(url, data: formData);
    
    return response.data['secure_url'];
  }

  // ------------------ ORDERS ---------------------- //
  Future<void> createOrder() async {
    throw UnimplementedError();
  }

  Stream<List<Order>> getVendorOrders(String vendorId) {
    return _firestore.collection('orders').where('vendorId', isEqualTo: vendorId).orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  Stream<List<Order>> getCustomerOrders(String customerId) {
    return _firestore.collection('orders').where('customerId', isEqualTo: customerId).orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({'status': status});
  }

  // This is the method that should be called from the OrderNotifier
  Future<void> placeOrderFromCart({
    required List<CartItem> cartItems,
    required double totalAmount,
    required String vendorId,
    required String deliveryOption,
    String? deliveryAddress,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception("You must be logged in to place an order.");

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    final orderData = {
      'customerId': user.uid,
      'customerName': userDoc.data()?['name'],
      'vendorId': vendorId,
      'totalAmount': totalAmount,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'deliveryOption': deliveryOption,
      'deliveryAddress': deliveryAddress, // Will be null for in-store pickup
      'items': cartItems.map((item) => {
        'quantity': item.quantity,
        'product': { 'id': item.product.id, 'name': item.product.name, 'price': item.product.price, 'image_url': item.product.imageUrl }
      }).toList(),
    };
    await _firestore.collection('orders').add(orderData);
  }

  // ------------------ CART ---------------------- //

  Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).collection('cart').get();
    return snapshot.docs.map((doc) => {'productId': doc.id, ...doc.data()}).toList();
  }

  Future<void> updateCartItem(String userId, String productId, int quantity) async {
    final cartItemRef = _firestore.collection('users').doc(userId).collection('cart').doc(productId);
    if (quantity > 0) {
      await cartItemRef.set({'quantity': quantity});
    } else {
      await cartItemRef.delete();
    }
  }

  Future<void> clearCart(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).collection('cart').get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

final apiService = ApiService();
