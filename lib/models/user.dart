class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String role; // customer or vendor

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.role,
  });

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
    );
  }
}
