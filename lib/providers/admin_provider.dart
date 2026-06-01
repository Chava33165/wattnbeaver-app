import 'package:flutter/material.dart';
import '../models/admin_user.dart';
import '../models/system_stats.dart';
import '../models/server_health.dart';
import '../services/api/admin_api.dart';

class AdminProvider extends ChangeNotifier {
  // Users
  List<AdminUser> _users = [];
  bool _isLoadingUsers = false;
  String? _usersError;

  // Stats
  SystemStats? _stats;
  bool _isLoadingStats = false;
  String? _statsError;

  // Server health
  ServerHealth? _serverHealth;
  bool _isLoadingServer = false;
  String? _serverError;

  // Shared operation state (update / delete)
  bool _isOperating = false;
  String? _operationError;

  List<AdminUser> get users => _users;
  bool get isLoadingUsers => _isLoadingUsers;
  String? get usersError => _usersError;

  SystemStats? get stats => _stats;
  bool get isLoadingStats => _isLoadingStats;
  String? get statsError => _statsError;

  ServerHealth? get serverHealth => _serverHealth;
  bool get isLoadingServer => _isLoadingServer;
  String? get serverError => _serverError;

  bool get isOperating => _isOperating;
  String? get operationError => _operationError;

  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    _usersError = null;
    notifyListeners();
    try {
      final response = await AdminApi.getUsers();
      final data = response['data'] ?? response;
      final list = data['users'] ?? data;
      _users = (list as List).map((u) => AdminUser.fromJson(u)).toList();
    } catch (e) {
      _usersError = e.toString();
    }
    _isLoadingUsers = false;
    notifyListeners();
  }

  Future<bool> updateUser(
    String id,
    Map<String, dynamic> body,
  ) async {
    _isOperating = true;
    _operationError = null;
    notifyListeners();
    try {
      await AdminApi.updateUser(id, body);
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx != -1) {
        _users[idx] = _users[idx].copyWith(
          name: body['name'],
          email: body['email'],
          role: body['role'],
        );
      }
      _isOperating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _operationError = e.toString();
      _isOperating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _isOperating = true;
    _operationError = null;
    notifyListeners();
    try {
      await AdminApi.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      _isOperating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _operationError = e.toString();
      _isOperating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadStats() async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();
    try {
      final response = await AdminApi.getStats();
      final data = response['data'] ?? response;
      final stats = data['stats'] ?? data;
      _stats = SystemStats.fromJson(stats as Map<String, dynamic>);
    } catch (e) {
      _statsError = e.toString();
    }
    _isLoadingStats = false;
    notifyListeners();
  }

  Future<void> loadServerHealth() async {
    _isLoadingServer = true;
    _serverError = null;
    notifyListeners();
    try {
      final response = await AdminApi.getServerHealth();
      final data = response['data'] ?? response;
      _serverHealth = ServerHealth.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      _serverError = e.toString();
    }
    _isLoadingServer = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([loadStats(), loadServerHealth()]);
  }

  void clearAll() {
    _users = [];
    _isLoadingUsers = false;
    _usersError = null;
    _stats = null;
    _isLoadingStats = false;
    _statsError = null;
    _serverHealth = null;
    _isLoadingServer = false;
    _serverError = null;
    _isOperating = false;
    _operationError = null;
    notifyListeners();
  }
}
