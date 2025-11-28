import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../data/dummy_data.dart';

class ShopProvider extends ChangeNotifier {
  final List<Shop> _shops = [];

  ShopProvider() {
    _shops.addAll(DummyDataService.getDummyShops());
  }

  List<Shop> get shops => _shops;

  List<Shop> getNearbyShops({double maxDistance = 5.0}) {
    return _shops.where((shop) => shop.distance <= maxDistance).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  Shop? getShop(String shopId) {
    try {
      return _shops.firstWhere((s) => s.id == shopId);
    } catch (e) {
      return null;
    }
  }

  List<Shop> getShopsByVendor(String vendorId) {
    return _shops.where((s) => s.vendorId == vendorId).toList();
  }
}
