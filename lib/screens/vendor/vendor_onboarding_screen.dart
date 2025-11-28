import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart';

class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<VendorOnboardingScreen> createState() =>
      _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  int _currentStep = 0;
  final _shopNameController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _selectedCategory;

  final categories = [
    'Saloon',
    'Mechanic Shops',
    'Cyber Cafes',
    'Pet Care',
    'Tailors',
  ];

  @override
  void dispose() {
    _shopNameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    if (_shopNameController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final vendorProvider = context.read<VendorProvider>();

    if (authProvider.currentUser != null) {
      vendorProvider.registerNewVendor(
        authProvider.currentUser!.name,
        _shopNameController.text,
        _selectedCategory!,
        authProvider.currentUser!.phone,
        authProvider.currentUser!.email,
        authProvider.currentUser!.address,
        'https://via.placeholder.com/300?text=Shop',
      );

      Navigator.of(context).pushReplacementNamed('/vendor_dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Onboarding'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep == 0) {
                      if (_shopNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter shop name'),
                          ),
                        );
                        return;
                      }
                      setState(() => _currentStep = 1);
                    } else {
                      _completeOnboarding();
                    }
                  },
                  onStepCancel: _currentStep > 0
                      ? () => setState(() => _currentStep -= 1)
                      : null,
                  steps: [
                    Step(
                      title: const Text('Shop Details'),
                      isActive: _currentStep >= 0,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shop Name',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _shopNameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your shop name',
                              prefixIcon: const Icon(Icons.store_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Category'),
                      isActive: _currentStep >= 1,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Service Category',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          ...categories.map((cat) {
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: _selectedCategory == cat
                                    ? AppTheme.primary.withOpacity(0.1)
                                    : AppTheme.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: _selectedCategory == cat
                                            ? AppTheme.primary
                                            : AppTheme.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        cat,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
