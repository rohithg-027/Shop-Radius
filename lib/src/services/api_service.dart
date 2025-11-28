import 'dart:async';
import 'package:dio/dio.dart';
import '../core/constants.dart';

class ApiService {
  static bool useMock = true;

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
    final res = await _dio.post('/auth/signup', data: body);
    return res.data;
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'user': {'id': 'u1', 'name': 'Demo User', 'role': body['role'] ?? 'customer'},
        'token': 'mock-token'
      };
    }
    final res = await _dio.post('/auth/login', data: body);
    return res.data;
  }

  // ------------------ PRODUCTS ---------------------- //
  Future<List<dynamic>> getProducts({double? lat, double? lng}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockProducts();
    }
    final q = (lat != null && lng != null) ? '?lat=$lat&lng=$lng' : '';
    final res = await _dio.get('/products$q');
    return res.data as List<dynamic>;
  }

  Future<dynamic> createProduct(Map<String, dynamic> body, String token) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {...body, 'id': DateTime.now().millisecondsSinceEpoch.toString()};
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final res = await _dio.post('/products', data: body);
    return res.data;
  }

  Future<dynamic> updateProduct(String id, Map<String, dynamic> body, String token) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {...body, 'id': id};
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final res = await _dio.put('/products/$id', data: body);
    return res.data;
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

  // ------------------ AI ---------------------- //
  Future<dynamic> askAI(String question, String token) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return {
        'reply': 'Mock AI: For "$question", suggested restock items: Milk, Bread.'
      };
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final res = await _dio.post('/ai/ask', data: {'question': question});
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
