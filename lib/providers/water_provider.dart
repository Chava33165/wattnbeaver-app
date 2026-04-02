import 'package:flutter/material.dart';
import '../models/water_summary.dart';
import '../models/water_week.dart';
import '../services/api/water_api.dart';

class WaterProvider extends ChangeNotifier {
  WaterSummary? summary;
  WaterWeek? history;
  bool isLoading = false;
  String? error;
  String selectedPeriod = 'week';

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static (String, String) _dateRange(String period) {
    final now = DateTime.now();
    final today = _fmtDate(now);
    if (period == 'day') {
      return (today, today);
    } else if (period == 'month') {
      final firstOfMonth = DateTime(now.year, now.month, 1);
      return (_fmtDate(firstOfMonth), today);
    } else {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      return (_fmtDate(monday), today);
    }
  }

  Future<void> loadWater({String period = 'week'}) async {
    isLoading = true;
    error = null;
    selectedPeriod = period;
    notifyListeners();

    try {
      final (startDate, endDate) = _dateRange(period);
      final results = await Future.wait([
        WaterApi.getTotal(),
        WaterApi.getWeeklyStats(startDate: startDate, endDate: endDate),
      ]);
      final totalData = results[0]['data'] ?? results[0];
      summary = WaterSummary.fromJson(totalData);
      final historyOuter = results[1]['data'] ?? results[1];
      history = WaterWeek.fromWeeklyStats(historyOuter);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePeriod(String period) async {
    await loadWater(period: period);
  }
}
