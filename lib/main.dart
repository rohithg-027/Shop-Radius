import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/data_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/vendor/vendor_onboarding_screen.dart';
import 'screens/vendor/vendor_dashboard_screen.dart';

void main() {
  runApp(const LocaLinkApp());
}

class LocaLinkApp extends StatelessWidget {
  const LocaLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: MaterialApp(
        title: 'LocaLink',
        theme: AppTheme.getTheme(),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/customer_home': (context) => const CustomerHomeScreen(),
          '/vendor_onboarding': (context) => const VendorOnboardingScreen(),
          '/vendor_dashboard': (context) => const VendorDashboardScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }

        if (authProvider.selectedRole == 'vendor') {
          return const VendorOnboardingScreen();
        }

        return const CustomerHomeScreen();
      },
    );
  }
}
