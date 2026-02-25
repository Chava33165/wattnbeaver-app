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

  Future<void> loadDashboard() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        // Real endpoints:
        EnergyApi.getTotal(),                       // [0] → {data: {totalPower, totalEnergy, deviceCount, onlineDevices}}
        WaterApi.getTotal(),                         // [1] → {data: {totalFlow, totalVolume, sensorCount, onlineSensors}}
        EnergyApi.getHistory(period: 'week'),        // [2] → {data: {data: [{hour, avg_power, total_energy}]}}
        WaterApi.getHistory(period: 'week'),          // [3] → {data: {data: [{hour, avg_flow, total_volume}]}}
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

      // Energy history (week) → {data: [{hour, avg_power, total_energy}]}
      final energyHistoryOuter = results[2]['data'] ?? results[2];
      energyWeek = EnergyWeek.fromJson(energyHistoryOuter);

      // Water history (week) → {data: [{hour, avg_flow, total_volume}]}
      final waterHistoryOuter = results[3]['data'] ?? results[3];
      waterWeek = WaterWeek.fromJson(waterHistoryOuter);

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
