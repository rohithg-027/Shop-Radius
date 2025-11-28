class Order {
  final String id;
  final String customerId;
  final String vendorId;
  final List<OrderItem> items;
  final String status; // Pending, Accepted, Completed
  final double totalAmount;
  final DateTime createdAt;
  final String deliveryAddress;
  final String customerName;
  final String phoneNumber;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.deliveryAddress,
    required this.customerName,
    required this.phoneNumber,
  });

  Order copyWith({
    String? id,
    String? customerId,
    String? vendorId,
    List<OrderItem>? items,
    String? status,
    double? totalAmount,
    DateTime? createdAt,
    String? deliveryAddress,
    String? customerName,
    String? phoneNumber,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      items: items ?? this.items,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });
}
