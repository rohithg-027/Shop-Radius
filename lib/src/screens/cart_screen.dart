import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart'; // Will be our new BillingScreen

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: cartItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Iconsax.shopping_bag, size: 60, color: Colors.grey), SizedBox(height: 16), Text('Your cart is empty.')],
              ),
            );
          }
          final cartTotal = ref.watch(cartTotalProvider);
          return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(item.product.imageUrl),
                        ),
                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          '₹${item.subtotal.toStringAsFixed(0)}',
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(item.quantity > 1 ? Iconsax.minus : Iconsax.trash, color: theme.colorScheme.error, size: 18),
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    ref.read(cartProvider.notifier).decrement(item.product.id);
                                  } else {
                                    ref.read(cartProvider.notifier).remove(item.product.id);
                                  }
                                },
                              ),
                              Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(Iconsax.add, color: theme.colorScheme.primary, size: 18),
                                onPressed: () => ref.read(cartProvider.notifier).increment(item.product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:', style: theme.textTheme.titleLarge),
                      Text('₹${cartTotal.toStringAsFixed(0)}', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ),
                ),
              ],
            );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Could not load cart: $err')),
      ),
    );
  }
}