import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final token = authState.token;

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(item.product.imageUrl),
                  ),
                  title: Text(item.product.name),
                  subtitle: Text("Qty: ${item.qty}"),
                  trailing: Text("₹${(item.product.price * item.qty).toStringAsFixed(0)}"),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total:", style: Theme.of(context).textTheme.titleLarge),
                Text("₹${cartNotifier.total.toStringAsFixed(0)}", style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: "CHECKOUT",
              onPressed: cartItems.isEmpty || user == null
                  ? null
                  : () async {
                      final items = cartItems.map((e) => {'product_id': e.product.id, 'qty': e.qty}).toList();
                      // Corrected lines
                      final body = {'shop_id': 's1', 'customer_id': user.id, 'items': items, 'total': cartNotifier.total, 'delivery_option': 'pickup'};
                      final res = await apiService.createOrder(body, token ?? '');
                      // Handle response
                      print(res);
                    },
            ),
          ],
        ),
      ),
    );
  }
}