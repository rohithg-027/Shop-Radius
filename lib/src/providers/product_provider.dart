import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final productListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final data = await apiService.getProducts();
  return data.map<Product>((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});
