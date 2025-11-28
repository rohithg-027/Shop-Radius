import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'cart_screen.dart';
import 'customer_home.dart';
import 'profile_screen.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('$title Screen')));
}

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    CustomerHomeScreen(), // Our new home screen
    _PlaceholderScreen(title: 'Wishlist'),
    CartScreen(), // Changed from Orders to Cart
    ProfileScreen(), // Existing profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Iconsax.home_2), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.heart), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Iconsax.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Iconsax.profile_circle), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}