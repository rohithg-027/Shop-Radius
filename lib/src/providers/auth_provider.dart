import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.user, this.token, this.isLoading = false, this.errorMessage});

  AuthState copyWith({User? user, String? token, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> signup({
    required String name,
    String? shopName,
    required String email,
    required String phone,
    required String password,
    String? address,
    String? businessType,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await apiService.signup({
        'name': name,
        'shopName': shopName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'address': address,
        'businessType': businessType
      });
      final user = User.fromJson(result['user']);
      state = AuthState(user: user, token: result['token'], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await apiService.login({'identifier': identifier, 'password': password, 'role': role});
      final user = User.fromJson(result['user']);
      state = AuthState(user: user, token: result['token'], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await apiService.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  void logout() {
    // In a real app, you would also call an API to invalidate the token
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// A derived provider to easily access just the user object
final userProvider = Provider<User?>((ref) => ref.watch(authProvider).user);