class SystemStats {
  final int totalUsers;
  final int totalDevices;
  final int totalEnergyReadings;
  final int totalWaterReadings;
  final int totalAlerts;
  final int totalPointsAwarded;
  final double avgPointsPerUser;
  final int activeStreaks;

  SystemStats({
    required this.totalUsers,
    required this.totalDevices,
    required this.totalEnergyReadings,
    required this.totalWaterReadings,
    required this.totalAlerts,
    required this.totalPointsAwarded,
    required this.avgPointsPerUser,
    required this.activeStreaks,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      totalUsers: int.tryParse(json['total_users']?.toString() ?? '0') ?? 0,
      totalDevices: int.tryParse(json['total_devices']?.toString() ?? '0') ?? 0,
      totalEnergyReadings: int.tryParse(json['total_energy_readings']?.toString() ?? '0') ?? 0,
      totalWaterReadings: int.tryParse(json['total_water_readings']?.toString() ?? '0') ?? 0,
      totalAlerts: int.tryParse(json['total_alerts']?.toString() ?? '0') ?? 0,
      totalPointsAwarded: int.tryParse(json['total_points_awarded']?.toString() ?? '0') ?? 0,
      avgPointsPerUser: double.tryParse(json['avg_points_per_user']?.toString() ?? '0') ?? 0.0,
      activeStreaks: int.tryParse(json['active_streaks']?.toString() ?? '0') ?? 0,
    );
  }
}
