class Category {
  final String id;
  final String name;
  final String imageUrl;
  final String? iconName;

  Category({required this.id, required this.name, required this.imageUrl, this.iconName});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      iconName: json['iconName'],
    );
  }
}