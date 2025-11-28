import 'package:flutter/material.dart';
import 'package:animated_gradient/animated_gradient.dart';
import 'package:iconsax/iconsax.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: AnimatedGradient(
        colors: [theme.colorScheme.background, theme.colorScheme.background.withOpacity(0.8)],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Your App Logo/Icon can go here
                Icon(
                  Iconsax.shop,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome to ShopRadius",
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Connect with local vendors and discover products right in your neighborhood.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color),
                ),
                const Spacer(flex: 2),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/role_select', arguments: {'isLogin': false}),
                  child: const Text("Create an Account"),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/role_select', arguments: {'isLogin': true}),
                  child: const Text("Login"),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}