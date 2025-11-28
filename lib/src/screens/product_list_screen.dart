import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../widgets/vendor_product_tile.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final prodAsync = ref.watch(productListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      body: prodAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,s) => Center(child: Text('Error: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => VendorProductTile(product: list[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pushNamed(c, '/product_edit'), child: const Icon(Icons.add)),
    );
  }
}
