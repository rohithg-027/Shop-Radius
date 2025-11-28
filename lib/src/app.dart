import 'package:flutter/material.dart';

// Theme
import 'core/theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/customer_home.dart';
import 'screens/vendor_dashboard.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_edit_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/ai_assistant_screen.dart';

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
        '/role': (_) => const RoleSelectScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),

        // Customer side
        '/customer': (_) => const CustomerHome(),
        '/cart': (_) => const CartScreen(),

        // Vendor side
        '/vendor': (_) => const VendorDashboard(),
        '/products': (_) => const ProductListScreen(),
        '/product_edit': (_) => const ProductEditScreen(),

        // AI
        '/ai': (_) => const AIAssistantScreen(),
      },
    );
  }
}
