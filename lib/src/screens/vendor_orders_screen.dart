import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class VendorOrdersScreen extends ConsumerWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersStream = ref.watch(vendorOrdersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders")),
      body: ordersStream.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("You have no orders yet."));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text("Order #${order.id.substring(0, 6)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("From: ${order.customerName ?? 'Customer'}\n${DateFormat.yMMMd().add_jm().format(order.createdAt.toDate())}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("₹${order.totalAmount.toStringAsFixed(0)}", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _buildStatusChip(context, order.status),
                    ],
                  ),
                  onTap: () => _showUpdateStatusDialog(context, ref, order),
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

  void _showUpdateStatusDialog(BuildContext context, WidgetRef ref, Order order) {
    final possibleStatuses = ['Pending', 'Accepted', 'Preparing', 'Out for Delivery', 'Completed', 'Cancelled'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Order Status"),
        content: DropdownButtonFormField<String>(
          value: order.status,
          items: possibleStatuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
          onChanged: (newStatus) {
            if (newStatus != null) {
              ref.read(orderProvider.notifier).updateOrderStatus(order.id, newStatus);
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'Cancelled':
        color = Colors.red;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      default:
        color = Theme.of(context).colorScheme.primary;
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      side: BorderSide.none,
    );
  }
}