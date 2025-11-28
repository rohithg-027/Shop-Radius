import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final productListProvider = FutureProvider.autoDispose.family<List<Product>, String?>((ref, vendorId) async {
  final data = await apiService.getProducts(vendorId: vendorId);
  return data.map<Product>((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});
