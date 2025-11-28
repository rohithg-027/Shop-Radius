import 'package:flutter/material.dart';
import '../models/vendor.dart';
import '../data/dummy_data.dart';

class VendorProvider extends ChangeNotifier {
  Vendor? _currentVendor;
  final List<Vendor> _vendors = [];

  Vendor? get currentVendor => _currentVendor;
  List<Vendor> get vendors => _vendors;

  VendorProvider() {
    _vendors.addAll(DummyDataService.getDummyVendors());
  }

  void setCurrentVendor(Vendor vendor) {
    _currentVendor = vendor;
    notifyListeners();
  }

  void updateVendorProfile(Vendor vendor) {
    _currentVendor = vendor;
    final index = _vendors.indexWhere((v) => v.id == vendor.id);
    if (index >= 0) {
      _vendors[index] = vendor;
    }
    notifyListeners();
  }

  void registerNewVendor(String name, String shopName, String category, 
      String phone, String email, String address, String shopImage) {
    final newVendor = Vendor(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      shopName: shopName,
      category: category,
      phone: phone,
      email: email,
      address: address,
      shopImage: shopImage,
      serviceIds: [],
    );
    _vendors.add(newVendor);
    _currentVendor = newVendor;
    notifyListeners();
  }

  Vendor? getVendor(String vendorId) {
    try {
      return _vendors.firstWhere((v) => v.id == vendorId);
    } catch (e) {
      return null;
    }
  }
}
