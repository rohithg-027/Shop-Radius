import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  Widget _buildStatusChip(BuildContext context, int stock) {
    final theme = Theme.of(context);
    String label;
    Color color;
    if (stock <= 0) {
      label = "Out of Stock";
      color = theme.colorScheme.error;
    } else if (stock < 10) {
      label = "Low Stock";
      color = Colors.orange.shade700;
    } else {
      label = "In Stock";
      color = Colors.green.shade700;
    }
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      padding: EdgeInsets.zero,
      side: BorderSide.none,
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                try {
                  await apiService.deleteProduct(product.id);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text('"${product.name}" deleted successfully.')));
                  ref.invalidate(productListProvider); // Refresh the list
                } catch (e) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorId = ref.watch(userProvider)?.id;
    final asyncProducts = ref.watch(productListProvider(vendorId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Products")),
      body: asyncProducts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text("No products found. Add your first product!"));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(product.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₹${product.price.toStringAsFixed(0)} • ${product.category ?? 'General'}"),
                      const SizedBox(height: 4),
                      _buildStatusChip(context, product.stock),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Iconsax.edit), onPressed: () => Navigator.pushNamed(context, '/product_edit', arguments: product)),
                      IconButton(icon: Icon(Iconsax.trash, color: theme.colorScheme.error), onPressed: () => _showDeleteConfirmation(context, ref, product)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/product_edit'),
        label: const Text("Add Product"),
        icon: const Icon(Iconsax.add),
      ),
    );
  }
}