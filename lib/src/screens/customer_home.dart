import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final prodAsync = ref.watch(productListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Products')),
      body: prodAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (list) => GridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: MediaQuery.of(c).size.width > 800 ? 4 : 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: list.map((p) => ProductCard.fromModel(product: p)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(c, '/cart'),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
