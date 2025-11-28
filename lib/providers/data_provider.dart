import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/service.dart';
import '../models/order.dart';
import '../models/service_booking.dart';
import '../data/dummy_data.dart';
import 'package:uuid/uuid.dart';

class DataProvider extends ChangeNotifier {
  static const uuid = Uuid();
  
  late List<Product> _products;
  late List<Service> _services;
  final List<Order> _orders = [];
  final List<ServiceBooking> _serviceBookings = [];

  DataProvider() {
    _products = DummyDataService.getDummyProducts();
    _services = DummyDataService.getDummyServices();
  }

  // Products
  List<Product> get products => _products;
  
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> getProductsByShop(String shopId) {
    return _products.where((p) => p.shopId == shopId).toList();
  }

  // Services
  List<Service> get services => _services;
  
  List<Service> getServicesByCategory(String category) {
    return _services.where((s) => s.category == category).toList();
  }

  List<Service> getServicesByVendor(String vendorId) {
    return _services.where((s) => s.vendorId == vendorId).toList();
  }

  // Orders
  List<Order> get orders => _orders;

  void placeOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String status) {
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex >= 0) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(status: status);
      notifyListeners();
    }
  }

  Order? getOrder(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<Order> getOrdersByCustomer(String customerId) {
    return _orders.where((o) => o.customerId == customerId).toList();
  }

  List<Order> getOrdersByVendor(String vendorId) {
    return _orders.where((o) => o.vendorId == vendorId).toList();
  }

  // Service Bookings
  List<ServiceBooking> get serviceBookings => _serviceBookings;

  void bookService(ServiceBooking booking) {
    _serviceBookings.add(booking);
    notifyListeners();
  }

  void updateServiceBookingStatus(String bookingId, String status) {
    final bookingIndex = _serviceBookings.indexWhere((b) => b.id == bookingId);
    if (bookingIndex >= 0) {
      _serviceBookings[bookingIndex] = _serviceBookings[bookingIndex].copyWith(status: status);
      notifyListeners();
    }
  }

  ServiceBooking? getServiceBooking(String bookingId) {
    try {
      return _serviceBookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  List<ServiceBooking> getServiceBookingsByCustomer(String customerId) {
    return _serviceBookings.where((b) => b.customerId == customerId).toList();
  }

  List<ServiceBooking> getServiceBookingsByVendor(String vendorId) {
    return _serviceBookings.where((b) => b.vendorId == vendorId).toList();
  }

  // Product Management for Vendors
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // Service Management for Vendors
  void addService(Service service) {
    _services.add(service);
    notifyListeners();
  }

  void updateService(Service service) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index >= 0) {
      _services[index] = service;
      notifyListeners();
    }
  }

  void deleteService(String serviceId) {
    _services.removeWhere((s) => s.id == serviceId);
    notifyListeners();
  }
}
