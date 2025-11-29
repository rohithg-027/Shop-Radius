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
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    service.description ?? 'No description available.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ElevatedButton(
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

}