import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider);
    final allProducts = ref.watch(productListProvider(null));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: wishlistIds.when(
        data: (ids) {
          if (ids.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }
          return allProducts.when(
            data: (products) {
              final wishlistProducts = products.where((p) => ids.contains(p.id)).toList();
              if (wishlistProducts.isEmpty) {
                return const Center(child: Text('No products found in your wishlist.'));
              }
              return ListView.builder(
                itemCount: wishlistProducts.length,
                itemBuilder: (context, index) {
                  final product = wishlistProducts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(product.imageUrl),
                    ),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(Iconsax.trash, color: theme.colorScheme.error),
                      onPressed: () {
                        ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
