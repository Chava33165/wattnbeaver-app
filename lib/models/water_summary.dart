// Real API response: {totalFlow: "X.XX", totalVolume: "X.XX", sensorCount: N, onlineSensors: N}
class WaterSummary {
  final double totalLiters;
  final double avgFlow;
  final double peakFlow;
  final double changePercent;
  final int sensorCount;
  final int onlineSensors;

  WaterSummary({
    required this.totalLiters,
    required this.avgFlow,
    required this.peakFlow,
    required this.changePercent,
    required this.sensorCount,
    required this.onlineSensors,
  });

  factory WaterSummary.fromJson(Map<String, dynamic> json) {
    return WaterSummary(
      totalLiters: double.tryParse(json['totalVolume']?.toString() ?? '0') ?? 0.0,
      avgFlow: double.tryParse(json['totalFlow']?.toString() ?? '0') ?? 0.0,
      peakFlow: 0.0,
      changePercent: 0.0,
      sensorCount: json['sensorCount'] ?? 0,
      onlineSensors: json['onlineSensors'] ?? 0,
    );
  }
}
