import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authProvider.notifier);
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final role = args?['role'] ?? 'customer';

      final success = await authNotifier.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text.trim(),
        role: role,
      );

      if (mounted && !success) {
        final error = ref.read(authProvider.select((state) => state.errorMessage));
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(error ?? "An unknown error occurred.")),
          );
      } else if (mounted && success) {
        final userRole = ref.read(userProvider)!.role;
        final route = userRole == 'vendor' ? '/vendor' : '/customer_home';
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text("Welcome Back!", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text("Login to continue your shopping.", style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _identifierController,
                labelText: "Email or Phone",
                prefixIcon: Iconsax.user,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value?.isEmpty ?? true) ? "Please enter your email or phone" : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
                prefixIcon: Iconsax.lock,
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Iconsax.eye_slash : Iconsax.eye),
                  onPressed: _togglePasswordVisibility,
                ),
                validator: (value) => (value?.isEmpty ?? true) ? "Please enter your password" : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "LOGIN",
                onPressed: isLoading ? null : _login,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}