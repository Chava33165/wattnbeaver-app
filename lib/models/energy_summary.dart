// Real API response: {totalPower: "X.XX", totalEnergy: "X.XXX", deviceCount: N, onlineDevices: N}
class EnergySummary {
  final double totalKwh;
  final double avgPower;
  final double peakPower;
  final double changePercent;
  final int deviceCount;
  final int onlineDevices;

  EnergySummary({
    required this.totalKwh,
    required this.avgPower,
    required this.peakPower,
    required this.changePercent,
    required this.deviceCount,
    required this.onlineDevices,
  });

  factory EnergySummary.fromJson(Map<String, dynamic> json) {
    return EnergySummary(
      totalKwh: double.tryParse(json['totalEnergy']?.toString() ?? '0') ?? 0.0,
      avgPower: double.tryParse(json['totalPower']?.toString() ?? '0') ?? 0.0,
      peakPower: 0.0,
      changePercent: 0.0,
      deviceCount: json['deviceCount'] ?? 0,
      onlineDevices: json['onlineDevices'] ?? 0,
    );
  }
}
