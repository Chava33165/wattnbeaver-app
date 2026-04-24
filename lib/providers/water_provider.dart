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

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> loadWater({String period = 'week'}) async {
    isLoading = true;
    error = null;
    selectedPeriod = period;
    notifyListeners();

    try {
      if (period == 'year') {
        final now = DateTime.now();
        final startDate = _fmt(DateTime(now.year, 1, 1));
        final endDate = _fmt(now);
        final results = await Future.wait([
          WaterApi.getTotal(),
          WaterApi.getWeeklyStats(startDate: startDate, endDate: endDate),
        ]);
        summary = WaterSummary.fromJson(results[0]['data'] ?? results[0]);
        history = WaterWeek.fromGroupedByMonth(results[1]['data'] ?? results[1]);
      } else {
        final results = await Future.wait([
          WaterApi.getTotal(),
          WaterApi.getHistory(period: period),
        ]);
        summary = WaterSummary.fromJson(results[0]['data'] ?? results[0]);
        final historyData = results[1]['data'] ?? results[1];
        history = period == 'day'
            ? WaterWeek.fromHourly(historyData)
            : WaterWeek.fromGroupedByDay(historyData);
      }
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
