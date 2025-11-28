class Vendor {
  final String id;
  final String name;
  final String shopName;
  final String category; // Service category: Saloon, Mechanic, etc.
  final String phone;
  final String email;
  final String address;
  final String shopImage;
  final List<String> serviceIds;
  final double rating;
  final int totalOrders;

  Vendor({
    required this.id,
    required this.name,
    required this.shopName,
    required this.category,
    required this.phone,
    required this.email,
    required this.address,
    required this.shopImage,
    required this.serviceIds,
    this.rating = 4.5,
    this.totalOrders = 0,
  });

  Vendor copyWith({
    String? id,
    String? name,
    String? shopName,
    String? category,
    String? phone,
    String? email,
    String? address,
    String? shopImage,
    List<String>? serviceIds,
    double? rating,
    int? totalOrders,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      shopImage: shopImage ?? this.shopImage,
      serviceIds: serviceIds ?? this.serviceIds,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }
}
