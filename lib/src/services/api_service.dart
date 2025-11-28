import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../core/constants.dart';
import '../models/category.dart';
import '../models/vendor.dart';

class ApiService {
  static bool useMock = false; // Set to false to use the live Firebase backend

  final _firestore = FirebaseFirestore.instance;
  final _firebaseAuth = fb_auth.FirebaseAuth.instance;
  // --- Cloudinary Configuration ---
  static const String _cloudinaryCloudName = "dq54lttbt"; // <-- IMPORTANT: REPLACE WITH YOUR CLOUD NAME
  static const String _cloudinaryUploadPreset = "shop_radius_unsigned"; // <-- IMPORTANT: REPLACE WITH YOUR PRESET NAME

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: BASE_URL,
      connectTimeout: Duration(milliseconds: 10000),
      receiveTimeout: Duration(milliseconds: 10000),
    ),
  );

  // ------------------ AUTH ---------------------- //
  Future<Map<String, dynamic>> signup(Map<String, dynamic> body) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'user': {'id': 'u1', 'name': body['name'], 'role': body['role']},
        'token': 'mock-token'
      };
    }
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
        print('The password provided is too weak.');
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        throw Exception('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        print('The email address is not valid.');
        throw Exception('The email address is not valid.');
      } else {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
        throw Exception('An unknown error occurred during signup.');
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred during signup.');
    }
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'user': {'id': 'u1', 'name': 'Demo User', 'role': body['role'] ?? 'customer'},
        'token': 'mock-token'
      };
    }

    // Find user by email first to check their role before full authentication.
    final userQuery = await _firestore.collection('users').where('email', isEqualTo: body['identifier']).limit(1).get();

    if (userQuery.docs.isEmpty) {
      throw Exception("No user found for that email. Please check the email or sign up.");
    }

    final userDoc = userQuery.docs.first;
    final storedRole = userDoc.data()['role'];
    final attemptedRole = body['role'];

    if (storedRole != attemptedRole) {
      // Provide a clear error message based on the mismatch.
      throw Exception("This is a '$storedRole' account. Please log in from the '$storedRole' portal.");
    }

    // If roles match, proceed with Firebase authentication.
    final cred = await _firebaseAuth.signInWithEmailAndPassword(email: body['identifier'], password: body['password']);
    final user = cred.user;
    if (user == null) throw Exception("Login failed: User not found.");

    return {'user': {...userDoc.data()!, 'id': user.uid}, 'token': await user.getIdToken()};
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // To avoid revealing if an email is registered, you might want to show a generic message.
        // However, for development, a specific message is helpful.
        throw Exception('No user found for that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception('An unknown error occurred. Please try again.');
      }
    } catch (e) {
      print('An unexpected error occurred during password reset: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // ------------------ PRODUCTS ---------------------- //
  Future<List<dynamic>> getProducts({String? vendorId}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockProducts();
    }

    Query query = _firestore.collection('products');
    if (vendorId != null) {
      query = query.where('vendorId', isEqualTo: vendorId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => <String, dynamic>{'id': doc.id, ...(doc.data() as Map<String, dynamic>? ?? {})}).toList();
  }

  Future<dynamic> createProduct(Map<String, dynamic> body, String token) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {...body, 'id': DateTime.now().millisecondsSinceEpoch.toString()};
    }

    final productId = body.remove('id');
    final productData = {
      ...body, 'vendorId': _firebaseAuth.currentUser?.uid,
    };

    if (productId != null) {
      // Update existing product
      await _firestore.collection('products').doc(productId).update(productData);
      return {'id': productId, ...productData};
    } else {
      // Create new product
      final docRef = await _firestore.collection('products').add({...productData, 'createdAt': FieldValue.serverTimestamp()});
      return {'id': docRef.id, ...productData};
    }
  }

  Future<void> deleteProduct(String productId) async {
    if (useMock) {
      print("Mock: Deleting product $productId");
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Could not delete product. Please try again.');
    }
  }

  // ------------------ SERVICES ---------------------- //
  Future<List<dynamic>> getCategories(String type) async {
    if (useMock) return _mockCategories(type);
    
    final snapshot = await _firestore.collection('categories').where('type', isEqualTo: type).get();
    return snapshot.docs.map((doc) => <String, dynamic>{
      'id': doc.id,
      ...(doc.data())
    }).toList();
  }

  Future<List<Vendor>> getVendors() async {
    if (useMock) return _mockVendors();

    // We fetch all users with the 'vendor' role.
    // In a large-scale app, this should be paginated or filtered by region on the backend.
    final snapshot = await _firestore.collection('users').where('role', isEqualTo: 'vendor').get();
    
    return snapshot.docs.map((doc) {
      return Vendor.fromJson(doc.id, doc.data());
    }).toList();
  }

  Future<dynamic> createService(Map<String, dynamic> body) async {
    final serviceId = body.remove('id');
    final serviceData = {
      ...body,
      'vendorId': _firebaseAuth.currentUser?.uid,
    };

    if (serviceId != null) {
      await _firestore.collection('services').doc(serviceId).update(serviceData);
      return {'id': serviceId, ...serviceData};
    } else {
      final docRef = await _firestore.collection('services').add({...serviceData, 'createdAt': FieldValue.serverTimestamp()});
      return {'id': docRef.id, ...serviceData};
    }
  }

  Future<List<dynamic>> getHotDeals() async {
    if (useMock) return _mockProducts()..shuffle();

    final snapshot = await _firestore.collection('products').where('isHotDeal', isEqualTo: true).limit(10).get();
    return snapshot.docs.map((doc) => <String, dynamic>{
      'id': doc.id,
      ...(doc.data())
    }).toList();
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
  Future<dynamic> createOrder(Map<String, dynamic> body, String token) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'order_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'status': 'CONFIRMED'
      };
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final res = await _dio.post('/orders', data: body);
    return res.data;
  }

  // ------------------ MOCK DATA ---------------------- //
  List<Map<String, dynamic>> _mockProducts() {
    return List.generate(10, (i) {
      return {
        'id': 'p$i',
        'name': i % 2 == 0 ? 'Milk ${i + 1}' : 'Bread ${i + 1}',
        'price': 25.0 + i * 5,
        'stock': i % 5 == 0 ? 0 : 5 + i,
        'image_url': 'https://picsum.photos/seed/p$i/400/300',
        'shop': {'id': 's1', 'name': 'Corner Store'}
      };
    });
  }

  List<Map<String, dynamic>> _mockCategories(String type) {
    if (type == 'product') {
      return [
        {'id': '1', 'name': 'Groceries', 'image_url': 'https://images.pexels.com/photos/3769747/pexels-photo-3769747.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': '2', 'name': 'Bakery', 'image_url': 'https://images.pexels.com/photos/1721934/pexels-photo-1721934.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': '3', 'name': 'Dairy', 'image_url': 'https://images.pexels.com/photos/248412/pexels-photo-248412.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': '4', 'name': 'Fresh Meat', 'image_url': 'https://images.pexels.com/photos/65175/pexels-photo-65175.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': '5', 'name': 'Stationery', 'image_url': 'https://images.pexels.com/photos/696644/pexels-photo-696644.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': '6', 'name': 'Gift Shops', 'image_url': 'https://images.pexels.com/photos/414579/pexels-photo-414579.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': '7', 'name': 'Clothing', 'image_url': 'https://images.pexels.com/photos/102129/pexels-photo-102129.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': '8', 'name': 'Medicine', 'image_url': 'https://images.pexels.com/photos/3683041/pexels-photo-3683041.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
      ];
    } else if (type == 'service') {
      return [
        {'id': 's1', 'name': 'Salon', 'image_url': 'https://images.pexels.com/photos/3998419/pexels-photo-3998419.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': 's2', 'name': 'Mechanic', 'image_url': 'https://images.pexels.com/photos/4488649/pexels-photo-4488649.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': 's3', 'name': 'Cyber Café', 'image_url': 'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': 's4', 'name': 'Laundry', 'image_url': 'https://images.pexels.com/photos/6723528/pexels-photo-6723528.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': 's5', 'name': 'Gaming', 'image_url': 'https://images.pexels.com/photos/7915228/pexels-photo-7915228.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': 's6', 'name': 'Pet Shop', 'image_url': 'https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': 's7', 'name': 'Home Repair', 'image_url': 'https://images.pexels.com/photos/5691533/pexels-photo-5691533.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
        {'id': 's8', 'name': 'Electrician', 'image_url': 'https://images.pexels.com/photos/5777701/pexels-photo-5777701.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'},
      ];
    }
    return [];
  }
}

List<Vendor> _mockVendors() {
  // Hypothetical user location: Bangalore
  // These GeoPoints can be created in Firestore for your live data.
  final vendorsData = [
    Vendor.fromJson('v1', {'shopName': 'Green Grocers', 'businessType': 'Grocery Store', 'location': const GeoPoint(12.9716, 77.5946)}), // ~0km away (Priority)
    Vendor.fromJson('v2', {'shopName': 'Daily Bakes', 'businessType': 'Bakery', 'location': const GeoPoint(12.9800, 77.6000)}), // ~1.1km away (Priority)
    Vendor.fromJson('v3', {'shopName': 'Super Electronics', 'businessType': 'Electronics', 'location': const GeoPoint(12.9500, 77.6200)}), // ~3.1km away
    Vendor.fromJson('v4', {'shopName': 'The Book Nook', 'businessType': 'Book Store', 'location': const GeoPoint(12.9350, 77.5800)}), // ~4.4km away
  ];
  return vendorsData;
}



final apiService = ApiService();
