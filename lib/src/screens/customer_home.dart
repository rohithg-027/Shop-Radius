import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category.dart';
import 'filtered_service_list_screen.dart';
import 'filtered_product_list_screen.dart';
import 'product_detail_screen.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/product_card.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // Using scaffoldBackgroundColor from the theme
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _Header(),
          const SizedBox(height: 16),
          const _SearchBar(),
          const SizedBox(height: 24),
          const _PromotionalBanner(),
          const SizedBox(height: 32),
          const _NearbyStoresSection(),
          const SizedBox(height: 32),
          _CategoryGrid(title: "Explore Products", provider: productCategoriesProvider),
          const SizedBox(height: 32),
          _CategoryGrid(title: "Discover Services", provider: serviceCategoriesProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locationState = ref.watch(locationProvider);
    final locationNotifier = ref.read(locationProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 32),
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.location, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationState.isLoading
                            ? "Fetching location..."
                            : locationState.error != null
                                ? "Could not get location"
                                : locationState.placemark?.street ??
                                  locationState.placemark?.locality ??
                                  "Location not found",
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Your Location",
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // This button now refreshes both location and nearby vendors
                TextButton.icon(
                  onPressed: () {
                    locationNotifier.fetchLocation();
                    ref.invalidate(nearbyVendorsProvider);
                  },
                  icon: const Icon(Iconsax.location_tick, color: Colors.white),
                  label: const Text("Nearby", style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.notification, color: Colors.white),
                  onPressed: () {
                    // TODO: Navigate to notifications screen
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/search');
        },
        child: AbsorbPointer(
          child: Material(
            elevation: 4.0,
            shadowColor: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products or services...',
                prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromotionalBanner extends StatelessWidget {
  const _PromotionalBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.secondary.withOpacity(0.3), theme.colorScheme.primary.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "50% OFF",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                Text(
                  "On Your First Order",
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Icon(Iconsax.shopping_bag, size: 60, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

class _NearbyStoresSection extends ConsumerWidget {
  const _NearbyStoresSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyVendorsAsync = ref.watch(nearbyVendorsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Stores Near You",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        nearbyVendorsAsync.when(
          data: (vendors) {
            if (vendors.isEmpty) {
              return const SizedBox(height: 100, child: Center(child: Text("No stores found nearby.")));
            }
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  final vendor = vendors[index];
                  final isPriority = (vendor.distanceInKm ?? 99) <= 1.5;
                  return SizedBox(
                    width: 240,
                    child: InkWell(
                      onTap: () {
                        if (vendor.businessType == 'product') {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => FilteredProductListScreen(title: vendor.shopName ?? 'Store', provider: productListProvider(vendor.id)),
                          ));
                        } else {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => FilteredServiceListScreen(title: vendor.shopName ?? 'Store', vendorId: vendor.id),
                          ));
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        color: isPriority ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isPriority ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5) : BorderSide.none,
                        ),
                        child: Center(
                          child: ListTile(
                            title: Text(
                              vendor.shopName ?? 'Local Store',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${vendor.businessType ?? "Store"}\n${_getDistanceText(vendor.distanceInKm)}',
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
          error: (err, stack) => SizedBox(height: 100, child: Center(child: Text("Could not load stores: $err"))),
        ),
      ],
    );
  }
}

String _getDistanceText(double? distanceInKm) {
  if (distanceInKm == null) {
    return 'Distance unavailable';
  }
  if (distanceInKm <= 1.5) {
    // If it's a priority store, emphasize that it's nearby.
    return '${distanceInKm.toStringAsFixed(1)} km away (Nearby)';
  }
  return '${distanceInKm.toStringAsFixed(1)} km away';
}

class _CategoryGrid extends ConsumerWidget {
  final String title;
  final AutoDisposeFutureProvider<List<Category>> provider;

  const _CategoryGrid({required this.title, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(provider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          categoriesAsync.when(
            data: (items) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // A more standard 4-column layout
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9, // Adjusted for better button shape
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FilteredProductListScreen(title: item.name, provider: productsByCategoryProvider(item.name)),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 5))
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 60,  // Adjusted size for 4 columns
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade200),
                              errorWidget: (context, url, error) => const Icon(Iconsax.gallery_slash),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Could not load categories: $err')),
          ),
        ],
      ),
    );
  }
}
