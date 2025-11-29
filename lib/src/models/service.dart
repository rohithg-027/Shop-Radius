class Service {
  final String id;
  final String name;
  final double price;
  final String? description;
  final int? durationMinutes; // e.g., 30 for 30 minutes
  final String vendorId;
  final Map<String, dynamic> shop;

  Service({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.durationMinutes,
    required this.vendorId,
    required this.shop,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'],
      durationMinutes: json['duration_minutes'],
      vendorId: json['vendorId'] ?? '',
      shop: json['shop'] ?? {},
    );
  }
}