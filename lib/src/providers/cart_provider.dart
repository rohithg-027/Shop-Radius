import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(Product product) {
    // Check if the product is already in the cart
    for (var item in state) {
      if (item.product.id == product.id) {
        item.quantity++;
        state = [...state]; // Create a new list to trigger UI update
        return;
      }
    }
    // If not in cart, add as a new item
    state = [...state, CartItem(product: product)];
  }

  void remove(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void increment(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          CartItem(product: item.product, quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrement(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId && item.quantity > 1)
          CartItem(product: item.product, quantity: item.quantity - 1)
        else
          item,
    ];
  }

  void clear() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// A provider to calculate the total price of the cart
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  double total = 0.0;
  for (var item in cart) {
    total += item.subtotal;
  }
  return total;
});