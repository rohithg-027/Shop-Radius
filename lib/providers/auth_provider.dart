import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _selectedRole; // 'customer' or 'vendor'
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  String? get selectedRole => _selectedRole;
  bool get isLoggedIn => _isLoggedIn;

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void login(String name, String phone, String email, String address) {
    _currentUser = User(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      email: email,
      address: address,
      role: _selectedRole ?? 'customer',
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _selectedRole = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateProfile(String name, String address) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        address: address,
      );
      notifyListeners();
    }
  }
}
