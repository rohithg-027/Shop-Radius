import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shopNameController = TextEditingController(); // Add controller for Shop Name
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _shopNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && mounted) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _addressController.text = "${place.street}, ${place.locality}, ${place.postalCode}";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authProvider.notifier);
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final role = args?['role'] ?? 'customer';
      final businessType = args?['businessType'];

      final success = await authNotifier.signup(
        name: _nameController.text.trim(),
        shopName: role == 'vendor' ? _shopNameController.text.trim() : null,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        address: _addressController.text.trim(),
        role: role,
        businessType: businessType,
      );

      if (mounted && !success) {
        final error = ref.read(authProvider.select((state) => state.errorMessage));
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(error ?? "An unknown error occurred.")),
          );
      } else if (mounted && success) {
        final route = role == 'vendor' ? '/vendor' : '/customer_home';
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final role = args?['role'] ?? 'customer';
    final title = "Create ${role == 'vendor' ? 'Vendor' : 'Customer'} Account";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text("Join ShopRadius", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text("Let's get you started.", style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _nameController,
                labelText: "Full Name",
                prefixIcon: Iconsax.user,
                validator: (value) => (value?.isEmpty ?? true) ? "Please enter your name" : null,
              ),
              const SizedBox(height: 16),
              if (role == 'vendor') ...[
                CustomTextField(
                  controller: _shopNameController,
                  labelText: "Shop Name",
                  prefixIcon: Iconsax.shop,
                  validator: (value) => (value?.isEmpty ?? true) ? "Please enter your shop name" : null,
                ),
                const SizedBox(height: 16),
              ],
              CustomTextField(
                controller: _emailController,
                labelText: "Email Address",
                prefixIcon: Iconsax.direct,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your email';
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: "Phone Number",
                prefixIcon: Iconsax.call,
                keyboardType: TextInputType.phone,
                validator: (value) => (value?.isEmpty ?? true) ? "Please enter your phone number" : null,
              ),
              const SizedBox(height: 16),
              if (role == 'vendor') ...[
                CustomTextField(
                  controller: _addressController,
                  labelText: "Shop/Service Address",
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.location_tick),
                    onPressed: _getCurrentLocation,
                  ),
                  validator: (value) => (value?.isEmpty ?? true) ? "Please enter your address" : null,
                ),
                const SizedBox(height: 16),
              ],
              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
                prefixIcon: Iconsax.lock,
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Iconsax.eye_slash : Iconsax.eye),
                  onPressed: _togglePasswordVisibility,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a password';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: "CREATE ACCOUNT",
                onPressed: isLoading ? null : _signup,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}