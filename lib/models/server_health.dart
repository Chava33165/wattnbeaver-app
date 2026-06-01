class MemoryInfo {
  final double totalMb;
  final double usedMb;
  final double freeMb;
  final double usagePercent;

  MemoryInfo({
    required this.totalMb,
    required this.usedMb,
    required this.freeMb,
    required this.usagePercent,
  });

  factory MemoryInfo.fromJson(Map<String, dynamic> json) {
    return MemoryInfo(
      totalMb: double.tryParse(json['total_mb']?.toString() ?? '0') ?? 0,
      usedMb: double.tryParse(json['used_mb']?.toString() ?? '0') ?? 0,
      freeMb: double.tryParse(json['free_mb']?.toString() ?? '0') ?? 0,
      usagePercent: double.tryParse(json['usage_percent']?.toString() ?? '0') ?? 0,
    );
  }
}

class ServerHealth {
  final MemoryInfo memory;
  final double? cpuTempCelsius;
  final int uptimeSeconds;
  final String platform;
  final String nodeVersion;

  ServerHealth({
    required this.memory,
    this.cpuTempCelsius,
    required this.uptimeSeconds,
    required this.platform,
    required this.nodeVersion,
  });

  factory ServerHealth.fromJson(Map<String, dynamic> json) {
    return ServerHealth(
      memory: MemoryInfo.fromJson(json['memory'] as Map<String, dynamic>),
      cpuTempCelsius: json['cpu_temp_celsius'] != null
          ? double.tryParse(json['cpu_temp_celsius'].toString())
          : null,
      uptimeSeconds: int.tryParse(json['uptime_seconds']?.toString() ?? '0') ?? 0,
      platform: json['platform']?.toString() ?? '',
      nodeVersion: json['node_version']?.toString() ?? '',
    );
  }

  String get uptimeFormatted {
    final d = Duration(seconds: uptimeSeconds);
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
