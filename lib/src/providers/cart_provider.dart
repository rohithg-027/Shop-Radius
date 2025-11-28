import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, this.qty);
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);
  void add(Product p) {
    final idx = state.indexWhere((c) => c.product.id == p.id);
    if (idx >= 0) {
      final copy = [...state];
      copy[idx].qty += 1;
      state = copy;
    } else {
      state = [...state, CartItem(p, 1)];
    }
  }

  void remove(String id) => state = state.where((c) => c.product.id != id).toList();

  void clear() => state = [];

  double get total => state.fold(0.0, (t, e) => t + e.product.price * e.qty);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());
