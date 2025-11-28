import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/cart_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
              errorWidget: (context, url, error) => Icon(Iconsax.gallery_slash, color: Colors.grey[400]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.shop['name'] ?? 'Local Store',
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("₹${product.price.toStringAsFixed(0)}", style: textTheme.titleLarge?.copyWith(color: theme.primaryColor)),
                    SizedBox(
                      height: 36, width: 36,
                      child: ElevatedButton(
                        onPressed: () => cart.add(product),
                        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: const CircleBorder()),
                        child: const Icon(Iconsax.shopping_bag, size: 18),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
