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
  String _deliveryOption = 'Home Delivery';
  bool _isPlacingOrder = false;

  void _placeOrder(String? deliveryAddress) async {
    if (_isPlacingOrder) return;

    setState(() => _isPlacingOrder = true);
    try {
      // The order provider will handle cart clearing on success
      await ref.read(orderProvider.notifier).placeOrder(
            deliveryOption: _deliveryOption,
            deliveryAddress: _deliveryOption == 'Home Delivery' ? deliveryAddress : null,
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
    final locationNotifier = ref.read(locationProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Delivery Option", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('Home Delivery'),
            value: 'Home Delivery',
            groupValue: _deliveryOption,
            onChanged: (value) {
              setState(() => _deliveryOption = value!);
              if (value == 'Home Delivery' && locationState.address == null) {
                locationNotifier.fetchLocation();
              }
            },
          ),
          if (_deliveryOption == 'Home Delivery')
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (locationState.isLoading)
                    const Text('Fetching location...')
                  else if (locationState.error != null)
                    Text('Error: ${locationState.error}', style: TextStyle(color: theme.colorScheme.error))
                  else if (locationState.address != null)
                    Text(locationState.address!)
                  else
                    const Text('Please fetch your location for delivery.'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: locationState.isLoading ? null : locationNotifier.fetchLocation,
                    icon: const Icon(Iconsax.location),
                    label: const Text('Get Current Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          RadioListTile<String>(
            title: const Text('In-Store Pickup'),
            subtitle: const Text('Pick up your order directly from the shop.'),
            value: 'In-Store Pickup',
            groupValue: _deliveryOption,
            onChanged: (value) {
              setState(() {
                _deliveryOption = value!;
              });
            },
          ),
          const Divider(height: 32),
          Text("Order Summary", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...cartItems.map((item) => ListTile(
                title: Text(item.product.name),
                subtitle: Text('Qty: ${item.quantity}'),
                trailing: Text('₹${item.subtotal.toStringAsFixed(0)}'),
              )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: theme.textTheme.titleLarge),
              Text('₹${cartTotal.toStringAsFixed(0)}', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: (cartItems.isEmpty || _isPlacingOrder || (_deliveryOption == 'Home Delivery' && locationState.address == null))
              ? null
              : () => _placeOrder(locationState.address),
          icon: _isPlacingOrder
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Iconsax.shopping_bag),
          label: Text(_isPlacingOrder ? "Placing Order..." : "Place Order & Pay on Delivery/Pickup"),
        ),
      ),
    );
  }
}