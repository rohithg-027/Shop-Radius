import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'cart_screen.dart';
import 'customer_home.dart';
import 'customer_orders_screen.dart';
import 'profile_screen.dart';
import '../providers/location_provider.dart';
import '../providers/cart_provider.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('$title Screen')));
}

class CustomerMainScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const CustomerMainScreen({super.key, this.initialIndex = 0}); // Corrected constructor

  @override
  ConsumerState<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends ConsumerState<CustomerMainScreen> {
  late int _selectedIndex;

  static const List<Widget> _widgetOptions = <Widget>[
    CustomerHomeScreen(), // Our new home screen
    CartScreen(),
    CustomerOrdersScreen(),
    ProfileScreen(), // Existing profile screen
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Fetch location as soon as the main screen is initialized.
    ref.read(locationProvider.notifier).fetchLocation();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Iconsax.home_2), label: 'Home'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(cartItems.valueOrNull?.length.toString() ?? '0'),
              isLabelVisible: cartItems.valueOrNull?.isNotEmpty ?? false,
              child: const Icon(Iconsax.shopping_bag),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Iconsax.receipt_2_1), label: 'Orders'), // Index 2
          const BottomNavigationBarItem(icon: Icon(Iconsax.profile_circle), label: 'Profile'), // Index 3
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}