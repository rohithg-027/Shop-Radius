import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);
    final searchNotifier = ref.read(searchNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products and services...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            // A debounce mechanism here would be ideal for production apps
            // to avoid excessive API calls.
            searchNotifier.searchProducts(query);
          },
        ),
      ),
      body: _buildBody(context, searchState),
    );
  }

  Widget _buildBody(BuildContext context, SearchState searchState) {
    // If the user hasn't typed anything, show a prompt.
    if (searchState.query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_normal_1, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Start typing to find what you need', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    // Show results based on the async state.
    return searchState.results.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(child: Text('No results found for "${searchState.query}".'));
        }
        // Display the list of found products.
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: const Icon(Iconsax.box),
              title: Text(product.name),
              subtitle: Text(product.shop['name'] ?? 'Local Store'),
              trailing: Text("₹${product.price.toStringAsFixed(0)}"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('An error occurred: $err')),
    );
  }
}