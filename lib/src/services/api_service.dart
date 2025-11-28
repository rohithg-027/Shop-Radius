import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../core/constants.dart';

class ApiService {
  static bool useMock = false; // We are now using live Firebase!

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
    // Note: Simple email login. In a real app, you might check phone numbers too.
    final cred = await _firebaseAuth.signInWithEmailAndPassword(email: body['identifier'], password: body['password']);
    final user = cred.user;
    if (user == null) throw Exception("Login failed: User not found.");

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      // This case is rare but good to handle. It means auth user exists but no DB record.
      await _firebaseAuth.signOut(); // Log them out to be safe
      throw Exception("User record not found. Please sign up again.");
    }

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
}

final apiService = ApiService();
