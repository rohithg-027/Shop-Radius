import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class ServiceListScreen extends ConsumerWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Services")),
      body: const Center(
        child: Text(
          "Service management coming soon!",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/service_edit'),
        label: const Text("Add Service"),
        icon: const Icon(Iconsax.add),
      ),
    );
  }
}