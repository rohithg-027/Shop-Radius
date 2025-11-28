import 'package:flutter/material.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Role')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
            icon: const Icon(Icons.store),
            label: const Text('I am a Vendor'),
            onPressed: () => Navigator.pushNamed(c, '/signup', arguments: {'role': 'vendor'}),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('I am a Customer'),
            onPressed: () => Navigator.pushNamed(c, '/signup', arguments: {'role': 'customer'}),
          )
        ]),
      ),
    );
  }
}
