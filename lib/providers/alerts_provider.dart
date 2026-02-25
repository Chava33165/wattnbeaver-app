import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/api/alerts_api.dart';

class AlertsProvider extends ChangeNotifier {
  List<Alert> alerts = [];
  bool isLoading = false;
  String? error;
  String filterSeverity = 'all';

  List<Alert> get filteredAlerts {
    if (filterSeverity == 'all') return alerts;
    return alerts.where((a) => a.severity == filterSeverity).toList();
  }

  int get unreadCount => alerts.where((a) => !a.acknowledged).length;

  Future<void> loadAlerts({bool? acknowledged}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await AlertsApi.getAlerts(
        acknowledged: acknowledged,
        limit: 50,
      );
      // Response: {data: {alerts: [], total: N, filters: {}}}
      final data = response['data'] ?? response;
      final list = data['alerts'] ?? data;
      alerts = (list is List)
          ? list.map((a) => Alert.fromJson(a)).toList()
          : [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acknowledgeAlert(String id) async {
    try {
      await AlertsApi.acknowledgeAlert(id);
      final index = alerts.indexWhere((a) => a.id == id);
      if (index != -1) {
        alerts[index] = Alert(
          id: alerts[index].id,
          type: alerts[index].type,
          severity: alerts[index].severity,
          message: alerts[index].message,
          deviceId: alerts[index].deviceId,
          data: alerts[index].data,
          acknowledged: true,
          createdAt: alerts[index].createdAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setFilter(String severity) {
    filterSeverity = severity;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
