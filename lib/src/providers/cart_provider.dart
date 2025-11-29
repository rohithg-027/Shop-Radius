import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartNotifier extends StateNotifier<AsyncValue<List<CartItem>>> {
  final String? _userId;

  CartNotifier(this._userId) : super(const AsyncLoading()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (_userId == null) {
      state = const AsyncData([]); // Not logged in, empty cart
      return;
    }
    try {
      final cartData = await apiService.getCart(_userId!);
      if (cartData.isEmpty) {
        state = const AsyncData([]);
        return;
      }

      // Fetch full product details for each item in the cart
      final productIds = cartData.map((item) => item['productId'] as String).toList();
      final productsSnapshot = await apiService.getProductsByIds(productIds);
      final productsMap = {for (var p in productsSnapshot) p.id: p};

      final cartItems = cartData.map((itemData) {
        final product = productsMap[itemData['productId']];
        if (product != null) {
          return CartItem(product: product, quantity: itemData['quantity']);
        }
        return null;
      }).whereType<CartItem>().toList(); // Filter out any nulls if a product was deleted

      state = AsyncData(cartItems);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> add(Product product) async {
    if (_userId == null) return; // Or show an error "Please log in"
    final currentCart = state.valueOrNull ?? [];
    final existingItem = currentCart.where((item) => item.product.id == product.id).firstOrNull;

    final newQuantity = (existingItem?.quantity ?? 0) + 1;
    await apiService.updateCartItem(_userId!, product.id, newQuantity);

    if (existingItem != null) {
      existingItem.quantity = newQuantity;
      state = AsyncData([...currentCart]);
    } else {
      state = AsyncData([...currentCart, CartItem(product: product, quantity: 1)]);
    }
  }

  Future<void> remove(String productId) async {
    if (_userId == null) return;
    await apiService.updateCartItem(_userId!, productId, 0); // Quantity 0 deletes
    state = AsyncData(state.valueOrNull?.where((item) => item.product.id != productId).toList() ?? []);
  }

  Future<void> increment(String productId) async {
    if (_userId == null) return;
    final item = state.valueOrNull?.where((i) => i.product.id == productId).firstOrNull;
    if (item == null) return;

    final newQuantity = item.quantity + 1;
    await apiService.updateCartItem(_userId!, productId, newQuantity);
    item.quantity = newQuantity;
    state = AsyncData([...state.value!]);
  }

  Future<void> decrement(String productId) async {
    if (_userId == null) return;
    final item = state.valueOrNull?.where((i) => i.product.id == productId).firstOrNull;
    if (item == null) return;

    final newQuantity = item.quantity - 1;
    await apiService.updateCartItem(_userId!, productId, newQuantity);

    if (newQuantity > 0) {
      item.quantity = newQuantity;
      state = AsyncData([...state.value!]);
    } else {
      // Remove if quantity drops to 0
      state = AsyncData(state.value!.where((i) => i.product.id != productId).toList());
    }
  }

  Future<void> clear() async {
    if (_userId == null) return;
    await apiService.clearCart(_userId!);
    state = const AsyncData([]);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<List<CartItem>>>((ref) {
  final userId = ref.watch(userProvider)?.id;
  return CartNotifier(userId);
});

// A provider to calculate the total price of the cart
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).when(
    data: (cartItems) {
      double total = 0.0;
      for (var item in cartItems) {
        total += item.subtotal;
      }
      return total;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});