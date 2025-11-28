import 'package:cloud_firestore/cloud_firestore.dart';

class Vendor {
  final String id;
  final String? name;
  final String? shopName;
  final String? businessType;
  final GeoPoint? location;
  double? distanceInKm; // Will be calculated on the client side

  Vendor({
    required this.id,
    this.name,
    this.shopName,
    this.businessType,
    this.location,
    this.distanceInKm,
  });

  factory Vendor.fromJson(String id, Map<String, dynamic> json) {
    return Vendor(
      id: id,
      name: json['name'],
      shopName: json['shopName'],
      businessType: json['businessType'],
      location: json['location'] as GeoPoint?,
    );
  }
}