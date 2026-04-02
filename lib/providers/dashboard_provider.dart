import 'package:flutter/material.dart';
import '../models/energy_summary.dart';
import '../models/water_summary.dart';
import '../models/energy_week.dart';
import '../models/water_week.dart';
import '../models/device.dart';
import '../models/gamification.dart';
import '../models/alert.dart';
import '../services/api/energy_api.dart';
import '../services/api/water_api.dart';
import '../services/api/device_api.dart';
import '../services/api/gamification_api.dart';
import '../services/api/alerts_api.dart';

class DashboardProvider extends ChangeNotifier {
  EnergySummary? energySummary;
  WaterSummary? waterSummary;
  EnergyWeek? energyWeek;
  WaterWeek? waterWeek;
  List<Device> devices = [];
  Gamification? gamification;
  List<Alert> recentAlerts = [];
  bool isLoading = true;
  String? error;

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startDate = _fmtDate(monday);
    final endDate = _fmtDate(now);

    try {
      final results = await Future.wait([
        EnergyApi.getTotal(),                        // [0] → {data: {totalPower, totalEnergy, deviceCount, onlineDevices}}
        WaterApi.getTotal(),                          // [1] → {data: {totalFlow, totalVolume, sensorCount, onlineSensors}}
        EnergyApi.getWeeklyStats(startDate: startDate, endDate: endDate), // [2] → {data: [{fecha, consumo_dia_kwh, ...}]}
        WaterApi.getWeeklyStats(startDate: startDate, endDate: endDate),  // [3] → {data: [{fecha, consumo_dia_litros, ...}]}
        DeviceApi.getDevices(),                      // [4] → {data: {devices: [], stats: {}, total: N}}
        GamificationApi.getProfile(),               // [5] → {data: {profile: {total_points, current_level, ...}}}
        AlertsApi.getAlerts(acknowledged: false, limit: 3), // [6] → {data: {alerts: [], total: N}}
      ]);

      // Energy total
      final energyData = results[0]['data'] ?? results[0];
      energySummary = EnergySummary.fromJson(energyData);

      // Water total
      final waterData = results[1]['data'] ?? results[1];
      waterSummary = WaterSummary.fromJson(waterData);

      // Energy weekly stats → {data: [{fecha, consumo_dia_kwh, ...}]}
      final energyHistoryOuter = results[2]['data'] ?? results[2];
      energyWeek = EnergyWeek.fromWeeklyStats(energyHistoryOuter);

      // Water weekly stats → {data: [{fecha, consumo_dia_litros, ...}]}
      final waterHistoryOuter = results[3]['data'] ?? results[3];
      waterWeek = WaterWeek.fromWeeklyStats(waterHistoryOuter);

      // Devices → {devices: [], stats: {}, total: N}
      final deviceOuter = results[4]['data'] ?? results[4];
      final deviceList = deviceOuter['devices'] ?? deviceOuter;
      devices = (deviceList is List)
          ? deviceList.map((d) => Device.fromJson(d)).toList()
          : [];

      // Gamification profile → {profile: {...}}
      final gamificationOuter = results[5]['data'] ?? results[5];
      final gamificationData = gamificationOuter['profile'] ?? gamificationOuter;
      gamification = Gamification.fromJson(gamificationData);

      // Alerts → {alerts: [], total: N}
      final alertOuter = results[6]['data'] ?? results[6];
      final alertList = alertOuter['alerts'] ?? alertOuter;
      recentAlerts = (alertList is List)
          ? alertList.map((a) => Alert.fromJson(a)).toList()
          : [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateEnergyFromMqtt(double power) {
    if (energySummary == null) return;
    energySummary = EnergySummary(
      totalKwh: energySummary!.totalKwh,
      avgPower: power,
      peakPower:
          power > energySummary!.peakPower ? power : energySummary!.peakPower,
      changePercent: energySummary!.changePercent,
      deviceCount: energySummary!.deviceCount,
      onlineDevices: energySummary!.onlineDevices,
    );
    notifyListeners();
  }

  void updateWaterFromMqtt(double flow) {
    if (waterSummary == null) return;
    waterSummary = WaterSummary(
      totalLiters: waterSummary!.totalLiters,
      avgFlow: flow,
      peakFlow:
          flow > waterSummary!.peakFlow ? flow : waterSummary!.peakFlow,
      changePercent: waterSummary!.changePercent,
      sensorCount: waterSummary!.sensorCount,
      onlineSensors: waterSummary!.onlineSensors,
    );
    notifyListeners();
  }
}
