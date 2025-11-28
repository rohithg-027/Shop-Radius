class User {
  final String id;
  final String name;
  final String role;
  final String? token;

  User({required this.id, required this.name, required this.role, this.token});

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'].toString(),
    name: j['name'] ?? '',
    role: j['role'] ?? 'customer',
    token: j['token'],
  );
}
