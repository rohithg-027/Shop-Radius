import 'package:flutter/material.dart';

class VendorDashboard extends StatelessWidget {
  const VendorDashboard({super.key});
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Corner Store'),
              subtitle: const Text('Today sales: ₹1,230'),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 12, children: [
            ElevatedButton.icon(onPressed: () => Navigator.pushNamed(c, '/product_edit'), icon: const Icon(Icons.add), label: const Text('Add Product')),
            ElevatedButton.icon(onPressed: () => Navigator.pushNamed(c, '/products'), icon: const Icon(Icons.list), label: const Text('Manage Products')),
            ElevatedButton.icon(onPressed: () => Navigator.pushNamed(c, '/ai'), icon: const Icon(Icons.smart_toy), label: const Text('AI Assistant')),
          ]),
          const SizedBox(height: 20),
          const Expanded(child: Center(child: Text('Orders and product stats will appear here.'))),
        ]),
      ),
    );
  }
}
