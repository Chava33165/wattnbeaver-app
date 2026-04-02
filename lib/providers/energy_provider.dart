import 'package:flutter/material.dart';
import '../models/energy_summary.dart';
import '../models/energy_week.dart';
import '../services/api/energy_api.dart';

class EnergyProvider extends ChangeNotifier {
  EnergySummary? summary;
  EnergyWeek? history;
  bool isLoading = false;
  String? error;
  String selectedPeriod = 'week';

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> loadEnergy({String period = 'week'}) async {
    isLoading = true;
    error = null;
    selectedPeriod = period;
    notifyListeners();

    try {
      if (period == 'year') {
        // Año completo: 1 Ene → hoy, agrupado por mes
        final now = DateTime.now();
        final startDate = _fmt(DateTime(now.year, 1, 1));
        final endDate = _fmt(now);
        final results = await Future.wait([
          EnergyApi.getTotal(),
          EnergyApi.getWeeklyStats(startDate: startDate, endDate: endDate),
        ]);
        summary = EnergySummary.fromJson(results[0]['data'] ?? results[0]);
        history = EnergyWeek.fromGroupedByMonth(results[1]['data'] ?? results[1]);
      } else {
        final results = await Future.wait([
          EnergyApi.getTotal(),
          EnergyApi.getHistory(period: period),
        ]);
        summary = EnergySummary.fromJson(results[0]['data'] ?? results[0]);
        final historyData = results[1]['data'] ?? results[1];
        history = period == 'day'
            ? EnergyWeek.fromHourly(historyData)
            : EnergyWeek.fromGroupedByDay(historyData);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePeriod(String period) async {
    await loadEnergy(period: period);
  }
}
