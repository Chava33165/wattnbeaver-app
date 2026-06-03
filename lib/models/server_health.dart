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

class CpuInfo {
  final double? tempCelsius;
  final int cores;
  final String? model;
  final double loadAvg1m;
  final double loadAvg5m;
  final double loadAvg15m;
  final double loadPercent1m;

  CpuInfo({
    this.tempCelsius,
    required this.cores,
    this.model,
    required this.loadAvg1m,
    required this.loadAvg5m,
    required this.loadAvg15m,
    required this.loadPercent1m,
  });

  factory CpuInfo.fromJson(Map<String, dynamic> json) {
    return CpuInfo(
      tempCelsius: json['temp_celsius'] != null
          ? double.tryParse(json['temp_celsius'].toString())
          : null,
      cores: int.tryParse(json['cores']?.toString() ?? '1') ?? 1,
      model: json['model']?.toString(),
      loadAvg1m: double.tryParse(json['load_avg_1m']?.toString() ?? '0') ?? 0,
      loadAvg5m: double.tryParse(json['load_avg_5m']?.toString() ?? '0') ?? 0,
      loadAvg15m: double.tryParse(json['load_avg_15m']?.toString() ?? '0') ?? 0,
      loadPercent1m: double.tryParse(json['load_percent_1m']?.toString() ?? '0') ?? 0,
    );
  }
}

class DiskPartition {
  final String mountpoint;
  final double totalGb;
  final double usedGb;
  final double freeGb;
  final double usagePercent;

  DiskPartition({
    required this.mountpoint,
    required this.totalGb,
    required this.usedGb,
    required this.freeGb,
    required this.usagePercent,
  });

  factory DiskPartition.fromJson(String mountpoint, Map<String, dynamic> json) {
    return DiskPartition(
      mountpoint: mountpoint,
      totalGb: double.tryParse(json['total_gb']?.toString() ?? '0') ?? 0,
      usedGb: double.tryParse(json['used_gb']?.toString() ?? '0') ?? 0,
      freeGb: double.tryParse(json['free_gb']?.toString() ?? '0') ?? 0,
      usagePercent: double.tryParse(json['usage_percent']?.toString() ?? '0') ?? 0,
    );
  }
}

class ServerHealth {
  final MemoryInfo memory;
  final CpuInfo? cpu;
  final List<DiskPartition> disks;
  final double? cpuTempCelsius; // campo legacy del API anterior
  final int uptimeSeconds;
  final String platform;
  final String? arch;
  final String nodeVersion;

  ServerHealth({
    required this.memory,
    this.cpu,
    this.disks = const [],
    this.cpuTempCelsius,
    required this.uptimeSeconds,
    required this.platform,
    this.arch,
    required this.nodeVersion,
  });

  // Temperatura efectiva: nuevo campo cpu.temp_celsius o fallback al legacy
  double? get effectiveCpuTemp => cpu?.tempCelsius ?? cpuTempCelsius;

  factory ServerHealth.fromJson(Map<String, dynamic> json) {
    final diskMap = json['disk'] as Map<String, dynamic>?;
    final disks = diskMap?.entries
            .map((e) => DiskPartition.fromJson(e.key, e.value as Map<String, dynamic>))
            .toList() ??
        [];

    return ServerHealth(
      memory: MemoryInfo.fromJson(json['memory'] as Map<String, dynamic>),
      cpu: json['cpu'] != null
          ? CpuInfo.fromJson(json['cpu'] as Map<String, dynamic>)
          : null,
      disks: disks,
      cpuTempCelsius: json['cpu_temp_celsius'] != null
          ? double.tryParse(json['cpu_temp_celsius'].toString())
          : null,
      uptimeSeconds: int.tryParse(json['uptime_seconds']?.toString() ?? '0') ?? 0,
      platform: json['platform']?.toString() ?? '',
      arch: json['arch']?.toString(),
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
