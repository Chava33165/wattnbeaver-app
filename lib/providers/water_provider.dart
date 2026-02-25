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

  Future<void> loadWater({String period = 'week'}) async {
    isLoading = true;
    error = null;
    selectedPeriod = period;
    notifyListeners();

    try {
      final results = await Future.wait([
        WaterApi.getTotal(),
        WaterApi.getHistory(period: period),
      ]);

      // Total: {data: {totalFlow, totalVolume, sensorCount, onlineSensors}}
      final totalData = results[0]['data'] ?? results[0];
      summary = WaterSummary.fromJson(totalData);

      // History: {data: {data: [{hour, avg_flow, total_volume}]}}
      final historyOuter = results[1]['data'] ?? results[1];
      history = WaterWeek.fromJson(historyOuter);
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
