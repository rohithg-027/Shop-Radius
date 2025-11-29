import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../models/vendor.dart';

final productListProvider = FutureProvider.autoDispose.family<List<Product>, String?>((ref, vendorId) async {
  final data = await apiService.getProducts(vendorId: vendorId);
  return data.map<Product>((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});

final productCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  // Fetch product categories from the database via the API service.
  // This assumes you have a getProductCategories method in your ApiService.
  final data = await apiService.getCategories('product');
  return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
});

final serviceCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  // Fetch service categories from the database via the API service.
  final data = await apiService.getCategories('service');
  return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
});

final productsByCategoryProvider = FutureProvider.autoDispose.family<List<Product>, String>((ref, categoryName) async {
  final data = await apiService.getProducts(category: categoryName);
  return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});

// 1. New provider to fetch and cache the user's position.
final positionProvider = FutureProvider<Position>((ref) async {
  // This will only run once and the result will be cached.
  return await Geolocator.getCurrentPosition();
});

final nearbyVendorsProvider = FutureProvider.autoDispose<List<Vendor>>((ref) async {
  // 2. Watch the new positionProvider to get the cached location.
  final position = await ref.watch(positionProvider.future);

  final vendors = await apiService.getVendors();

  for (var vendor in vendors) {
    if (vendor.location != null) {
      vendor.distanceInKm = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        vendor.location!.latitude,
        vendor.location!.longitude,
      ) / 1000; // Convert meters to kilometers
    }
  }

  // Sort all vendors by distance first to find the closest ones.
  vendors.sort((a, b) => (a.distanceInKm ?? 999).compareTo(b.distanceInKm ?? 999));

  // Filter the list to only include vendors within 1.5km.
  final nearbyVendors = vendors.where((vendor) => (vendor.distanceInKm ?? 999) <= 1.5).toList();

  // **Smart Fallback Logic**: If no vendors are found within 1.5km,
  // show the 5 closest vendors instead of an empty list.
  if (nearbyVendors.isEmpty && vendors.isNotEmpty) {
    // Take the top 5 closest vendors from the already sorted list.
    return vendors.take(5).toList();
  }

  return nearbyVendors;
});

// Provider to fetch all products for a general "Explore" page.
final exploreProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  // Assumes getProducts() without parameters fetches all products.
  final data = await apiService.getProducts();
  return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});


/// --- Similarity Search Providers ---

// 1. Defines the state for our search screen.
class SearchState {
  final AsyncValue<List<Product>> results;
  final String query;

  SearchState({this.results = const AsyncValue.data([]), this.query = ''});

  SearchState copyWith({AsyncValue<List<Product>>? results, String? query}) {
    return SearchState(
      results: results ?? this.results,
      query: query ?? this.query,
    );
  }
}

// 2. StateNotifier to manage search logic.
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  Future<void> searchProducts(String query) async {
    // Update state to show loading indicator and store the query.
    state = state.copyWith(query: query, results: const AsyncValue.loading());

    if (query.isEmpty) {
      state = state.copyWith(results: const AsyncValue.data([]));
      return;
    }

    try {
      // This assumes you have a `searchProducts` method in your ApiService.
      final products = await apiService.searchProducts(query);
      state = state.copyWith(results: AsyncValue.data(products.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList()));
    } catch (e, st) {
      state = state.copyWith(results: AsyncValue.error(e, st));
    }
  }
}

// 3. Provider to expose the SearchNotifier to the UI.
final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});
