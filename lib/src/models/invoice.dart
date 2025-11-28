class Invoice {
  final String id;
  final List<dynamic> items;
  final double total;

  Invoice({required this.id, required this.items, required this.total});

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
    id: j['id'].toString(),
    items: j['items'] as List<dynamic>,
    total: (j['total'] ?? 0).toDouble(),
  );
}
