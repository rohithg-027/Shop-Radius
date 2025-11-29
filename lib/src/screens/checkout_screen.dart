import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../providers/cart_provider.dart';
import '../screens/customer_main_screen.dart';
import '../providers/order_provider.dart';
import '../providers/location_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isPlacingOrder = false;
  String _deliveryOption = 'Delivery Partner'; // New state for delivery option
  String _paymentMethod = 'UPI'; // Default payment method

  void _placeOrder() async {
    if (_isPlacingOrder) return;

    setState(() => _isPlacingOrder = true);
    try {
      // The order provider will handle cart clearing on success
      final deliveryAddress = _deliveryOption == 'Delivery Partner' ? ref.read(locationProvider).address : null;
      await ref.read(orderProvider.notifier).placeOrder(
            paymentMethod: _paymentMethod,
            deliveryAddress: deliveryAddress, // Address is passed for invoice purposes
          );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed Successfully!")));
      // Navigate to the main screen and land on the Orders tab.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerMainScreen(initialIndex: 2)), // 2 is the new index for Orders
        (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to place order: ${e.toString()}")));
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final locationState = ref.watch(locationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Delivery Option Section ---
          Text("Delivery Option", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('Delivery Partner'),
            subtitle: const Text('Your order will be delivered to your location.'),
            secondary: const Icon(Iconsax.truck),
            value: 'Delivery Partner',
            groupValue: _deliveryOption,
            onChanged: (value) {
              setState(() => _deliveryOption = value!);
            },
          ),
          if (_deliveryOption == 'Delivery Partner')
            Padding(
              padding: const EdgeInsets.only(left: 72, right: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (locationState.isLoading)
                    const Text('Fetching location...')
                  else if (locationState.error != null)
                    Text('Error: ${locationState.error}', style: TextStyle(color: theme.colorScheme.error))
                  else if (locationState.address != null)
                    Text(locationState.address!, style: theme.textTheme.bodySmall)
                  else
                    const Text('Location not available.'),
                ],
              ),
            ),
          RadioListTile<String>(
            title: const Text('In-hand Shop Pickup'),
            subtitle: const Text('You will pick up the order from the shop.'),
            secondary: const Icon(Iconsax.shop),
            value: 'Shop Pickup',
            groupValue: _deliveryOption,
            onChanged: (value) {
              setState(() {
                _deliveryOption = value!;
              });
            },
          ),

          const Divider(height: 32),

          // --- Invoice/Order Summary Section ---
          Text("Invoice Summary", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ...(cartItems.valueOrNull ?? []).map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item.product.name} (x${item.quantity})')),
                            Text('₹${item.subtotal.toStringAsFixed(0)}'),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('₹${cartTotal.toStringAsFixed(0)}', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 32),

          // --- Payment Method Section ---
          Text("Payment Method", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('UPI (Pay on Scan)'),
            subtitle: const Text('Google Pay, PhonePe, Paytm, etc.'),
            secondary: const Icon(Iconsax.card),
            value: 'UPI',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() => _paymentMethod = value!);
            },
          ),
          RadioListTile<String>(
            title: const Text('Cash on Delivery / Pickup'),
            subtitle: const Text('Pay with cash when you receive your order.'),
            secondary: const Icon(Iconsax.money),
            value: 'Cash',
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() => _paymentMethod = value!);
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: ((cartItems.valueOrNull?.isEmpty ?? true) || _isPlacingOrder)
              ? null : _placeOrder,
          icon: _isPlacingOrder
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Iconsax.shopping_bag),
          label: Text(_isPlacingOrder ? "Placing Order..." : "Confirm Order"),
        ),
      ),
    );
  }
}