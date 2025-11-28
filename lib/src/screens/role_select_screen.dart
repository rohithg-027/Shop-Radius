import 'package:flutter/material.dart';
import 'package:animated_gradient/animated_gradient.dart';
import 'package:iconsax/iconsax.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  Widget _roleCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isLogin = arguments?['isLogin'] ?? false;
    final String title = isLogin ? "Login As" : "Join As A...";
    final String routeName = isLogin ? "/login" : "/signup";
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(title)),
      body: AnimatedGradient(
        colors: [theme.colorScheme.background, theme.colorScheme.background.withOpacity(0.8)],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                _roleCard(
                  context,
                  icon: Iconsax.building_4,
                  label: "Vendor",
                  description: "Set up your digital storefront and sell products to local customers.",
                  onTap: () {
                    // If signing up, go to vendor type selection. If logging in, go to login screen.
                    final nextRoute = isLogin ? routeName : '/vendor_type_select';
                    Navigator.pushNamed(context, nextRoute, arguments: {'role': 'vendor', 'isLogin': isLogin});
                  },
                ),
                const SizedBox(height: 24),
                _roleCard(
                  context,
                  icon: Iconsax.shopping_bag,
                  label: "Customer",
                  description: "Discover and buy from nearby shops with exclusive local deals.",
                  onTap: () => Navigator.pushNamed(context, routeName, arguments: {'role': 'customer'}),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
