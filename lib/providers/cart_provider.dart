import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'package:uuid/uuid.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  static const uuid = Uuid();

  List<CartItem> get items => _items;
  
  int get itemCount => _items.length;
  
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(Product product) {
    // Check if product already exists in cart
    final existingItemIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingItemIndex >= 0) {
      _items[existingItemIndex] = _items[existingItemIndex].copyWith(
        quantity: _items[existingItemIndex].quantity + 1,
      );
    } else {
      _items.add(
        CartItem(
          id: uuid.v4(),
          productId: product.id,
          name: product.name,
          price: product.price,
          image: product.image,
          quantity: 1,
          shopId: product.shopId,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int quantity) {
    final itemIndex = _items.indexWhere((item) => item.id == cartItemId);
    if (itemIndex >= 0) {
      if (quantity <= 0) {
        removeFromCart(cartItemId);
      } else {
        _items[itemIndex] = _items[itemIndex].copyWith(quantity: quantity);
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  CartItem? getCartItem(String cartItemId) {
    try {
      return _items.firstWhere((item) => item.id == cartItemId);
    } catch (e) {
      return null;
    }
  }
}
