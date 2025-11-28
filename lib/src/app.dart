import 'package:flutter/material.dart';

// Theme
import 'core/theme.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/customer_home.dart';
import 'screens/vendor_dashboard.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_edit_screen.dart';
import 'screens/vendor_type_select_screen.dart';
import 'screens/service_list_screen.dart';
import 'screens/service_edit_screen.dart';
import 'screens/cart_screen.dart';

class ShopRadiusApp extends StatelessWidget {
  const ShopRadiusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopRadius',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),

      // Initial route
      initialRoute: '/',

      // All routes
      routes: {
        '/': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/role_select': (_) => const RoleSelectScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),

        // Customer side
        '/customer_home': (_) => const CustomerHome(),
        '/cart': (_) => const CartScreen(),

        // Vendor side
        '/vendor_type_select': (_) => const VendorTypeSelectScreen(),
        '/vendor': (_) => const VendorDashboard(),
        '/products': (_) => ProductListScreen(),
        '/product_edit': (_) => ProductEditScreen(),
        '/service_list': (_) => const ServiceListScreen(),
        '/service_edit': (_) => const ServiceEditScreen(),
      },
    );
  }
}
