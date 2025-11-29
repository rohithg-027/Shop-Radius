import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final wishlistProvider = StateNotifierProvider<WishlistNotifier, AsyncValue<List<String>>>((ref) {
  final userId = ref.watch(userProvider)?.id;
  return WishlistNotifier(userId);
});

class WishlistNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final String? _userId;

  WishlistNotifier(this._userId) : super(const AsyncLoading()) {
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    if (_userId == null) {
      state = const AsyncData([]);
      return;
    }
    try {
      final wishlist = await apiService.getWishlist(_userId!);
      state = AsyncData(wishlist);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> toggleWishlist(String productId) async {
    if (_userId == null) return;

    final currentWishlist = state.valueOrNull ?? [];
    if (currentWishlist.contains(productId)) {
      state = AsyncData(currentWishlist.where((id) => id != productId).toList());
    } else {
      state = AsyncData([...currentWishlist, productId]);
    }
    // Persist changes to the backend
    await apiService.updateWishlist(_userId!, state.value!);
  }
}