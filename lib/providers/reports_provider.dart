import 'package:flutter/material.dart';
import '../services/api/reports_api.dart';

class ReportsProvider extends ChangeNotifier {
  String selectedPeriod = 'monthly';
  Map<String, dynamic>? reportData;
  bool isLoading = false;
  String? error;

  // Tarifas del backend
  static const double kWhRate = 2.5;
  static const double literRate = 0.05;

  Future<void> loadReport({String? period}) async {
    if (period != null) selectedPeriod = period;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      Map<String, dynamic> response;
      switch (selectedPeriod) {
        case 'daily':
          response = await ReportsApi.getDaily();
        case 'weekly':
          response = await ReportsApi.getWeekly();
        default:
          response = await ReportsApi.getMonthly();
      }
      final data = response['data'] ?? response;
      reportData = (data['report'] ?? data) as Map<String, dynamic>?;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double get energyCost {
    if (reportData == null) return 0;
    return _extractDouble(
      _deepGet(reportData!, ['energy', 'totals', 'total_cost']) ??
          _deepGet(reportData!, ['totals', 'energy_cost']) ??
          _deepGet(reportData!, ['summary', 'energy_cost']),
    );
  }

  double get waterCost {
    if (reportData == null) return 0;
    return _extractDouble(
      _deepGet(reportData!, ['water', 'totals', 'total_cost']) ??
          _deepGet(reportData!, ['totals', 'water_cost']) ??
          _deepGet(reportData!, ['summary', 'water_cost']),
    );
  }

  double get totalCost {
    if (reportData == null) return 0;
    final direct = _deepGet(reportData!, ['summary', 'total_cost']) ??
        _deepGet(reportData!, ['totals', 'total_cost']);
    if (direct != null) return _extractDouble(direct);
    return energyCost + waterCost;
  }

  double get totalEnergy {
    if (reportData == null) return 0;
    return _extractDouble(
      _deepGet(reportData!, ['energy', 'totals', 'total_energy']) ??
          _deepGet(reportData!, ['totals', 'total_energy']) ??
          _deepGet(reportData!, ['summary', 'total_energy']),
    );
  }

  double get totalWater {
    if (reportData == null) return 0;
    return _extractDouble(
      _deepGet(reportData!, ['water', 'totals', 'total_volume']) ??
          _deepGet(reportData!, ['totals', 'total_water']) ??
          _deepGet(reportData!, ['summary', 'total_water']),
    );
  }

  List<dynamic> get deviceBreakdown {
    if (reportData == null) return [];
    return (reportData!['energy']?['devices'] as List<dynamic>?) ?? [];
  }

  dynamic _deepGet(Map<String, dynamic> data, List<String> keys) {
    dynamic current = data;
    for (final key in keys) {
      if (current is Map<String, dynamic>) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  double _extractDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '0') ?? 0.0;
}
