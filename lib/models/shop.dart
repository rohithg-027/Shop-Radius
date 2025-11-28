class Shop {
  final String id;
  final String name;
  final String image;
  final String address;
  final double distance; // in km
  final double rating;
  final String openingTime;
  final String closingTime;
  final bool isOpen;
  final String vendorId;

  Shop({
    required this.id,
    required this.name,
    required this.image,
    required this.address,
    required this.distance,
    required this.rating,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,
    required this.vendorId,
  });
}
