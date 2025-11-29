import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class CustomerOrdersScreen extends ConsumerWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersStream = ref.watch(customerOrdersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: ordersStream.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("You haven't placed any orders yet."));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text("Order #${order.id.substring(0, 6)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Placed on: ${DateFormat.yMMMd().format(order.createdAt.toDate())}"),
                  trailing: Chip(
                    label: Text(order.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: _getStatusColor(context, order.status),
                    padding: EdgeInsets.zero,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}