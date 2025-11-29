import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../models/service.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';

class OrderNotifier extends StateNotifier<AsyncValue<void>> {
  OrderNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> placeOrder({
    required String paymentMethod,
    String? deliveryOption, // Add deliveryOption
    String? deliveryAddress,
  }) async {
    state = const AsyncLoading();
    try {
      final cartItems = ref.read(cartProvider).value;
      if (cartItems == null || cartItems.isEmpty) {
        throw Exception("Cannot place an order with an empty cart.");
      }
      // Assumption: All items in the cart are from the same vendor.
      final vendorId = cartItems.first.product.shop['id'] as String;
      final totalAmount = ref.read(cartTotalProvider);

      await apiService.placeOrderFromCart(
          cartItems: cartItems,
          totalAmount: totalAmount,
          vendorId: vendorId,
          paymentMethod: paymentMethod,
          deliveryOption: deliveryOption ?? 'Shop Pickup', // Pass to API
          deliveryAddress: deliveryAddress);

      ref.read(cartProvider.notifier).clear(); // Clear cart on success
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> bookService(Service service) async {
    state = const AsyncLoading();
    try {
      await apiService.createServiceBooking(service: service);
      ref.invalidate(customerOrdersProvider); // Refresh the customer's order list
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await apiService.updateOrderStatus(orderId, status);
      ref.invalidate(vendorOrdersProvider); // Refresh the list
    } catch (e) {
      // Handle error, maybe show a snackbar
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, AsyncValue<void>>((ref) {
  return OrderNotifier(ref);
});

final vendorOrdersProvider = StreamProvider.autoDispose<List<Order>>((ref) {
  final vendorId = ref.watch(userProvider)?.id;
  if (vendorId == null) return Stream.value([]);
  return apiService.getVendorOrders(vendorId);
});

final customerOrdersProvider = StreamProvider.autoDispose<List<Order>>((ref) {
  final customerId = ref.watch(userProvider)?.id;
  if (customerId == null) return Stream.value([]);
  return apiService.getCustomerOrders(customerId);
});