import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../services/api/auth_api.dart';
import '../services/storage/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  bool get isAdmin => _user?.role == 'admin';

  Future<bool> checkAuth() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return false;

      if (JwtDecoder.isExpired(token)) {
        await StorageService.clear();
        return false;
      }

      // Real API: GET /auth/profile → {success, data: {user: {...}}, message}
      final response = await AuthApi.getProfile();
      final data = response['data'] ?? response;
      final userData = data['user'] ?? data;
      _user = User.fromJson(userData);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      await StorageService.clear();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthApi.login(email, password);
      final authResponse = AuthResponse.fromJson(response);

      await StorageService.saveToken(authResponse.token);
      await StorageService.saveUser(authResponse.user);

      _user = authResponse.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthApi.register(name, email, password);
      final authResponse = AuthResponse.fromJson(response);

      await StorageService.saveToken(authResponse.token);
      await StorageService.saveUser(authResponse.user);

      _user = authResponse.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clear();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
