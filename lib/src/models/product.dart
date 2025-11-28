class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String imageUrl;

  Product({required this.id, required this.name, required this.price, required this.stock, required this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'].toString(),
    name: j['name'] ?? '',
    price: (j['price'] ?? j['price_selling'] ?? 0).toDouble(),
    stock: (j['stock'] ?? 0) as int,
    imageUrl: j['image_url'] ?? '',
  );
}
