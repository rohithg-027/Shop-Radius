// Simple placeholder - not used directly in this version, kept for expansion.
import 'package:flutter/material.dart';

class CartBottomSheet extends StatelessWidget {
  final Widget child;
  const CartBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext c) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      maxChildSize: 0.9,
      minChildSize: 0.1,
      builder: (_, controller) => Container(
        color: Colors.white,
        child: ListView(controller: controller, children: [child]),
      ),
    );
  }
}
