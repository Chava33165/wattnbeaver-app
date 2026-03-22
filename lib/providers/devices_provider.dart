import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/api/device_api.dart';

class DevicesProvider extends ChangeNotifier {
  List<Device> devices = [];
  Device? selectedDevice;
  bool isLoading = false;
  String? error;
  String searchQuery = '';
  String filterType = 'all';

  List<Device> get filteredDevices {
    return devices.where((d) {
      final matchSearch = searchQuery.isEmpty ||
          d.deviceName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          d.location.toLowerCase().contains(searchQuery.toLowerCase());
      final matchType = filterType == 'all' || d.deviceType == filterType;
      return matchSearch && matchType;
    }).toList();
  }

  Future<void> loadDevices() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await DeviceApi.getDevices();
      // Response: {data: {devices: [], stats: {}, total: N}}
      final data = response['data'] ?? response;
      final list = data['devices'] ?? data;
      devices = (list is List)
          ? list.map((d) => Device.fromJson(d)).toList()
          : [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Device?> linkDevice({
    required String deviceId,
    required String deviceName,
    required String deviceType,
    String? location,
  }) async {
    try {
      final response = await DeviceApi.linkDevice({
        'device_id': deviceId,
        'device_name': deviceName,
        'device_type': deviceType,
        if (location != null) 'location': location,
      });
      final data = response['data'] ?? response;
      final newDevice = Device.fromJson(data['device'] ?? data);
      devices.insert(0, newDevice);
      notifyListeners();
      return newDevice;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<String?> rotateApiKey(String deviceId) async {
    try {
      final response = await DeviceApi.rotateApiKey(deviceId);
      final data = response['data'] ?? response;
      final updated = Device.fromJson(data['device'] ?? data);
      final idx = devices.indexWhere((d) => d.id == deviceId);
      if (idx != -1) {
        devices[idx] = updated;
        notifyListeners();
      }
      return updated.apiKey;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteDevice(String id) async {
    try {
      await DeviceApi.deleteDevice(id);
      devices.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      // No sobreescribir el error global para no reemplazar la pantalla
      return false;
    }
  }

  void setSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setFilter(String type) {
    filterType = type;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
