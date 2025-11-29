import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final searchProvider = StateNotifierProvider<SearchNotifier, AsyncValue<List<Product>>>((ref) {
  return SearchNotifier();
});

class SearchNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  SearchNotifier() : super(const AsyncData([]));

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    try {
      final results = await apiService.searchProducts(query);
      final products = results.map((data) => Product.fromJson(data as Map<String, dynamic>)).toList();
      state = AsyncData(products);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}