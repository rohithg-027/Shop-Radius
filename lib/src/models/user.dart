class User {
  final String id;
  final String? name;
  final String? email;
  final String role;
  final String? shopName;
  final String? businessType;

  User({required this.id, this.name, this.email, required this.role, this.shopName, this.businessType});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'] ?? 'customer',
        shopName: json['shopName'],
        businessType: json['businessType'],
      );
}