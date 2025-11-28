class Service {
  final String id;
  final String name;
  final String image;
  final double serviceCharge;
  final String availabilityStatus; // Available / Unavailable
  final String category;
  final String vendorId;
  final String description;
  final double rating;
  final String duration; // e.g., "1 hour", "30 mins"

  Service({
    required this.id,
    required this.name,
    required this.image,
    required this.serviceCharge,
    required this.availabilityStatus,
    required this.category,
    required this.vendorId,
    required this.description,
    this.rating = 4.5,
    required this.duration,
  });

  Service copyWith({
    String? id,
    String? name,
    String? image,
    double? serviceCharge,
    String? availabilityStatus,
    String? category,
    String? vendorId,
    String? description,
    double? rating,
    String? duration,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      category: category ?? this.category,
      vendorId: vendorId ?? this.vendorId,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
    );
  }
}
