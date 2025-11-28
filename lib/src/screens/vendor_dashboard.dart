import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/auth_provider.dart';

class VendorDashboard extends ConsumerStatefulWidget {
  const VendorDashboard({super.key});

  @override
  ConsumerState<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends ConsumerState<VendorDashboard> {
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() async {
    // Permissions are handled on the signup screen, but a check here is good practice
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  Widget _buildMetricCard(BuildContext context,
      {required String title, required String value, required IconData icon}) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context,
      {required String text, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: theme.textTheme.bodySmall)
        ],
      ),
    );
  }

  Widget _buildLowStockItem(BuildContext context, {required String name, required int stock}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const Icon(Iconsax.box_1, color: Colors.orange),
      title: Text(name),
      trailing: Text(
        "$stock left",
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
      ),
      onTap: () {},
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out and exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
        if (shouldLogout ?? false) {
          ref.read(authProvider.notifier).logout();
        }
        return shouldLogout ?? false;
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.25),
        appBar: AppBar(
          title: Text(user?.shopName ?? 'Vendor Dashboard'),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Text("Welcome, ${user?.name ?? 'Vendor'}", style: theme.textTheme.bodyMedium)),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                Navigator.pushNamedAndRemoveUntil(context, '/role_select', (route) => false);
              },
              icon: const Icon(Iconsax.logout),
            ),
            const SizedBox(width: 8)
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildMetricCard(context, title: "Today's Sales", value: "₹0", icon: Iconsax.money_recive),
                _buildMetricCard(context, title: "Orders Pending", value: "0", icon: Iconsax.receipt_2_1),
              ],
            ),
            const SizedBox(height: 24),

            // Live Location Map
            Card( // Replaced GoogleMap with a Card showing coordinates
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Live Location", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _currentPosition == null
                        ? const Row(children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(width: 16), Text("Fetching location...")])
                        : Row(
                            children: [
                              Icon(Iconsax.location, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text("Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}"),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quick Actions", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (user?.businessType == 'product') ...[
                          _buildQuickAction(context, text: "Add Product", icon: Iconsax.add_square, onTap: () => Navigator.pushNamed(context, '/product_edit')),
                          _buildQuickAction(context, text: "Update Stock", icon: Iconsax.box_tick, onTap: () => Navigator.pushNamed(context, '/products')),
                          _buildQuickAction(context, text: "Discounts", icon: Iconsax.discount_shape, onTap: () {}),
                        ] else ...[
                          _buildQuickAction(context, text: "Add Service", icon: Iconsax.add_square, onTap: () => Navigator.pushNamed(context, '/service_edit')),
                          _buildQuickAction(context, text: "Manage Bookings", icon: Iconsax.calendar_tick, onTap: () => Navigator.pushNamed(context, '/service_list')),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (user?.businessType == 'product') ...[
              const SizedBox(height: 24),

              // Low Stock Items
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Restock Alerts", style: theme.textTheme.titleMedium),
                      const Divider(height: 24),
                      const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("No low stock items.")))
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
