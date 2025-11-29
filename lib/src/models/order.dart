import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart'; // We can reuse CartItem for simplicity
import 'product.dart';

class Order {
  final String id;
  final String customerId;
  final String vendorId;
  final List<CartItem> items;
  final double totalAmount;
  final String status; // e.g., 'Pending', 'Accepted', 'Preparing', 'Completed', 'Cancelled'
  final Timestamp createdAt;
  final String? customerName;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.customerName,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      vendorId: data['vendorId'] ?? '',
      items: (data['items'] as List<dynamic>).map((itemData) {
        // This assumes a simplified structure. A real app might need a full Product.fromJson here.
        final productMap = itemData['product'] as Map<String, dynamic>;
        return CartItem(product: Product.fromJson(productMap), quantity: itemData['quantity']);
      }).toList(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Unknown',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      customerName: data['customerName'],
    );
  }
}