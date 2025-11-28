import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  // convenience constructor used in earlier widget usage
  factory ProductCard.fromModel({required Product product}) => ProductCard(product: product);

  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final inStock = product.stock > 0;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Expanded(child: product.imageUrl.isNotEmpty ? Image.network(product.imageUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,__,___)=> const Icon(Icons.image)) : const Icon(Icons.image, size: 64)),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(children: [
              Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              inStock ? ElevatedButton(onPressed: () => cart.add(product), child: const Icon(Icons.add_shopping_cart)) : const Chip(label: Text('Out of stock'))
            ])
          ]),
        )
      ]),
    );
  }
}
