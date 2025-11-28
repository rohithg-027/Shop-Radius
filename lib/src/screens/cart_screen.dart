import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final auth = ref.read(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Expanded(
                  child: ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final it = cart[i];
                        return ListTile(
                          leading: Image.network(it.product.imageUrl, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.image)),
                          title: Text(it.product.name),
                          subtitle: Text('Qty: ${it.qty}  •  ₹${(it.product.price * it.qty).toStringAsFixed(0)}'),
                          trailing: IconButton(onPressed: () => cartNotifier.remove(it.product.id), icon: const Icon(Icons.delete)),
                        );
                      }),
                ),
                const SizedBox(height: 12),
                Text('Total: ₹${ref.read(cartProvider.notifier).total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final items = cart.map((c) => {'product_id': c.product.id, 'qty': c.qty}).toList();
                    final body = {'shop_id': 's1', 'customer_id': auth?.id ?? 'guest', 'items': items, 'total': ref.read(cartProvider.notifier).total, 'delivery_option': 'pickup'};
                    final res = await apiService.createOrder(body, auth?.token ?? '');
                    showDialog(context: c, builder: (_) => AlertDialog(title: const Text('Order Created'), content: Text('Order id: ${res['order_id']}'), actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('OK'))]));
                    ref.read(cartProvider.notifier).clear();
                  },
                  child: const Text('Place Order'),
                )
              ]),
            ),
    );
  }
}
