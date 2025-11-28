import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authProvider.notifier);
      final success =
          await authNotifier.forgotPassword(_emailController.text.trim());

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();

        if (success) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text("Password reset link sent to your email."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          final error =
              ref.read(authProvider.select((state) => state.errorMessage));
          messenger.showSnackBar(
            SnackBar(
              content: Text(error ?? "An unknown error occurred."),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text("Reset Your Password", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text("Enter your email and we will send you a link to reset your password.", style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _emailController,
                labelText: "Email Address",
                prefixIcon: Iconsax.direct,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value?.isEmpty ?? true) ? "Please enter your email" : null,
              ),
              const SizedBox(height: 24),
              CustomButton(text: "SEND RESET LINK", onPressed: isLoading ? null : _sendResetLink, isLoading: isLoading),
            ],
          ),
        ),
      ),
    );
  }
}