import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/src/providers/auth_provider.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class CustomerHome extends ConsumerWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productListProvider(null)); // Pass null to get all products
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text("ShopRadius", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              automaticallyImplyLeading: false,
              floating: true,
              snap: true,
              actions: [
                IconButton(onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/role_select', (route) => false, arguments: {'isLogin': true});
                }, icon: const Icon(Iconsax.logout)),
                IconButton(onPressed: () {}, icon: const Icon(Iconsax.profile_circle)),
                const SizedBox(width: 8),
              ],
            ),
          ];
        },
        body: asyncProducts.when(
          loading: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
          error: (_, __) => const Center(child: Text("Something went wrong. Please try again.")),
          data: (list) => GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) => ProductCard(product: list[i]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/cart'),
        icon: const Icon(Iconsax.shopping_cart),
        label: const Text("View Cart"),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
