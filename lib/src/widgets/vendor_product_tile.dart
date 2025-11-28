import 'package:flutter/material.dart';
import '../models/product.dart';

class VendorProductTile extends StatelessWidget {
  final Product product;
  const VendorProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext c) {
    final stockText = product.stock > 0 ? 'In stock: ${product.stock}' : 'Out of stock';
    return ListTile(
      leading: product.imageUrl.isNotEmpty ? Image.network(product.imageUrl, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.image)) : const Icon(Icons.image),
      title: Text(product.name),
      subtitle: Text('₹${product.price.toStringAsFixed(0)} • $stockText'),
      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.pushNamed(c, '/product_edit')),
    );
  }
}
