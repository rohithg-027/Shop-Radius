class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final String stockStatus; // In Stock / Out of Stock
  final String category;
  final String shopId;
  final String description;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.stockStatus,
    required this.category,
    required this.shopId,
    required this.description,
    this.rating = 4.5,
  });

  Product copyWith({
    String? id,
    String? name,
    String? image,
    double? price,
    String? stockStatus,
    String? category,
    String? shopId,
    String? description,
    double? rating,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      stockStatus: stockStatus ?? this.stockStatus,
      category: category ?? this.category,
      shopId: shopId ?? this.shopId,
      description: description ?? this.description,
      rating: rating ?? this.rating,
    );
  }
}
