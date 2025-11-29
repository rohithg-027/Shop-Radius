import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../models/product.dart';
import '../screens/checkout_screen.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade200),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.name, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text("Sold by ${product.shop['name'] ?? 'Local Store'}", style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Text("₹${product.price.toStringAsFixed(0)}", style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 16),
          Text(product.description ?? "No description available for this product.", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text("Product Details", style: theme.textTheme.titleLarge),
          const Divider(height: 24),
          if (product.brand != null) ...[
            ListTile(
              leading: const Icon(Iconsax.tag),
              title: const Text("Brand"),
              subtitle: Text(product.brand!),
            ),
          ],
          if (product.category != null) ...[
            ListTile(
              leading: const Icon(Iconsax.category),
              title: const Text("Category"),
              subtitle: Text(product.category!),
            ),
          ],
          ListTile(
            leading: const Icon(Iconsax.box_1),
            title: const Text("Availability"),
            subtitle: Text(
              product.stock > 0 ? "In Stock" : "Out of Stock",
              style: TextStyle(color: product.stock > 0 ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Iconsax.shopping_bag),
                label: const Text("Add to Cart"),
                onPressed: () {
                  ref.read(cartProvider.notifier).add(product);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text("${product.name} added to cart.")));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // "Buy Now" adds to cart and navigates directly to cart
                  ref.read(cartProvider.notifier).add(product);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                },
                child: const Text("Buy Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}