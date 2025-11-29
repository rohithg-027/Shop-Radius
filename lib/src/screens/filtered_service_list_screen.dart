import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import '../providers/service_provider.dart';

class FilteredServiceListScreen extends ConsumerWidget {
  final String title;
  final String vendorId;

  const FilteredServiceListScreen({
    super.key,
    required this.title,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncServices = ref.watch(serviceListProvider(vendorId));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: asyncServices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (services) {
          if (services.isEmpty) {
            return const Center(child: Text("This vendor has not listed any services yet."));
          }
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("₹${service.price.toStringAsFixed(0)}"),
                  trailing: ElevatedButton(
                    onPressed: () => _showBookingConfirmation(context, service),
                    child: const Text("Book Now"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBookingConfirmation(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: Text("You are about to book '${service.name}'. This feature is coming soon!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}