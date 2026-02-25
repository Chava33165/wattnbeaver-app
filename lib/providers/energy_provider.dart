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

  Future<void> loadEnergy({String period = 'week'}) async {
    isLoading = true;
    error = null;
    selectedPeriod = period;
    notifyListeners();

    try {
      final results = await Future.wait([
        EnergyApi.getTotal(),
        EnergyApi.getHistory(period: period),
      ]);

      // Total: {data: {totalPower, totalEnergy, deviceCount, onlineDevices}}
      final totalData = results[0]['data'] ?? results[0];
      summary = EnergySummary.fromJson(totalData);

      // History: {data: {data: [{hour, avg_power, total_energy}]}}
      final historyOuter = results[1]['data'] ?? results[1];
      history = EnergyWeek.fromJson(historyOuter);
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
