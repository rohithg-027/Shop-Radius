class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final bool isAvailable;
  final String imageUrl;
  final Map<String, dynamic> shop;
  final bool isHotDeal;
  final String? category;
  final String? brand;
  final String? size;
  final String? description;
  final double? discount;

  Product({
    required this.id, required this.name, required this.price, required this.stock,
    required this.imageUrl, required this.shop, this.isHotDeal = false, this.isAvailable = true, this.category,
    this.brand, this.size, this.description, this.discount
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: (j['id'] ?? '').toString(),
    name: j['name'] ?? '',
    price: (j['price'] ?? j['price_selling'] ?? 0.0).toDouble(),
    stock: (j['stock'] ?? 0) as int,
    isAvailable: j['is_available'] ?? true,
    imageUrl: j['image_url'] ?? '',
    isHotDeal: j['is_hot_deal'] ?? j['isHotDeal'] ?? false,
    shop: j['shop'] ?? {},
    category: j['category'],
    brand: j['brand'],
    size: j['size'],
    description: j['description'],
    discount: (j['discount'] as num?)?.toDouble() ?? 0.0,
  );
}
