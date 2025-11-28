import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../models/category.dart';
import '../models/vendor.dart';

final productListProvider = FutureProvider.autoDispose.family<List<Product>, String?>((ref, vendorId) async {
  final data = await apiService.getProducts(vendorId: vendorId);
  return data.map<Product>((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});

final productCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  // Return a static list of general product categories with online images.
  return [
    Category(id: '1', name: 'Groceries', imageUrl: 'https://images.pexels.com/photos/3769747/pexels-photo-3769747.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: '2', name: 'Bakery', imageUrl: 'https://images.pexels.com/photos/1721934/pexels-photo-1721934.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: '3', name: 'Dairy', imageUrl: 'https://images.pexels.com/photos/248412/pexels-photo-248412.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: '4', name: 'Fresh Meat', imageUrl: 'https://images.pexels.com/photos/65175/pexels-photo-65175.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: '5', name: 'Stationery', imageUrl: 'https://images.pexels.com/photos/696644/pexels-photo-696644.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: '6', name: 'Gift Shops', imageUrl: 'https://images.pexels.com/photos/414579/pexels-photo-414579.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: '7', name: 'Clothing', imageUrl: 'https://images.pexels.com/photos/102129/pexels-photo-102129.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: '8', name: 'Medicine', imageUrl: 'https://images.pexels.com/photos/3683041/pexels-photo-3683041.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
  ];
});

final serviceCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  // Return a static list of general service categories with online images.
  return [
    Category(id: 's1', name: 'Salon', imageUrl: 'https://images.pexels.com/photos/3998419/pexels-photo-3998419.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: 's2', name: 'Mechanic', imageUrl: 'https://images.pexels.com/photos/4488649/pexels-photo-4488649.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: 's3', name: 'Cyber Café', imageUrl: 'https://images.pexels.com/photos/1779487/pexels-photo-1779487.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: 's4', name: 'Laundry', imageUrl: 'https://images.pexels.com/photos/6723528/pexels-photo-6723528.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: 's5', name: 'Gaming', imageUrl: 'https://images.pexels.com/photos/7915228/pexels-photo-7915228.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: 's6', name: 'Pet Shop', imageUrl: 'https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: 's7', name: 'Home Repair', imageUrl: 'https://images.pexels.com/photos/5691533/pexels-photo-5691533.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
    Category(id: 's8', name: 'Electrician', imageUrl: 'https://images.pexels.com/photos/5777701/pexels-photo-5777701.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
  ];
});

final hotDealsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final data = await apiService.getHotDeals();
  return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});

final nearbyVendorsProvider = FutureProvider.autoDispose<List<Vendor>>((ref) async {
  // 1. Get user's current position
  final position = await Geolocator.getCurrentPosition();

  // 2. Fetch all vendors from the backend
  final vendors = await apiService.getVendors();

  // 3. Calculate distance for each vendor and sort them
  for (var vendor in vendors) {
    if (vendor.location != null) {
      vendor.distanceInKm = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        vendor.location!.latitude,
        vendor.location!.longitude,
      ) / 1000; // Convert meters to kilometers
    }
  }

  // Sort by distance (closest first)
  vendors.sort((a, b) => (a.distanceInKm ?? 999).compareTo(b.distanceInKm ?? 999));

  return vendors;
});
