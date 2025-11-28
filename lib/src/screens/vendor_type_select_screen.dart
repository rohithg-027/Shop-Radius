import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class VendorTypeSelectScreen extends StatelessWidget {
  const VendorTypeSelectScreen({super.key});

  Widget _typeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isLogin = arguments?['isLogin'] ?? false;
    final nextRoute = isLogin ? "/login" : "/signup";
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Your Business Type"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _typeCard(
                context,
                icon: Iconsax.box,
                title: "Product Business",
                subtitle: "Grocery, Bakery, Gifts, Pharma, Clothing, and more.",
                onTap: () => Navigator.pushNamed(context, nextRoute, arguments: {'role': 'vendor', 'businessType': 'product'}),
              ),
              const SizedBox(height: 24),
              _typeCard(
                context,
                icon: Iconsax.magic_star,
                title: "Service Business",
                subtitle: "Salon, Mechanic, Pet Care, Cyber Cafe, and more.",
                onTap: () => Navigator.pushNamed(context, nextRoute, arguments: {'role': 'vendor', 'businessType': 'service'}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}