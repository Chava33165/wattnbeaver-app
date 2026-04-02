// Real API history: {data: [{hour: "2024-01-01T00:00:00", avg_flow: X, total_volume: X}]}
class WaterDay {
  final String date;
  final double totalLiters;

  WaterDay({required this.date, required this.totalLiters});
}

class WaterWeek {
  final List<WaterDay> days;
  final double weekTotal;
  final double weekAvg;

  WaterWeek({
    required this.days,
    required this.weekTotal,
    required this.weekAvg,
  });

  // Nuevo formato: {data: [{fecha, dia_semana, consumo_dia_litros, flujo_promedio_lmin, ...}]}
  factory WaterWeek.fromWeeklyStats(Map<String, dynamic> json) {
    final rows = json['data'] as List? ?? [];

    final days = rows.map((r) {
      final date = r['fecha'] as String? ?? '';
      final totalLiters =
          (r['consumo_dia_litros'] as num?)?.toDouble() ?? 0.0;
      return WaterDay(date: date, totalLiters: totalLiters);
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalLiters);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return WaterWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }

  // json is the inner data object: {data: [{hour, avg_flow, total_volume}]}
  factory WaterWeek.fromJson(Map<String, dynamic> json) {
    final hourlyData = json['data'] as List? ?? [];

    // Group by date (first 10 chars of hour string)
    final Map<String, List<dynamic>> byDay = {};
    for (final item in hourlyData) {
      final hour = item['hour'] as String? ?? '';
      final date = hour.length >= 10 ? hour.substring(0, 10) : hour;
      byDay.putIfAbsent(date, () => []).add(item);
    }

    // Create WaterDay per date
    final days = byDay.entries.map((e) {
      final dayData = e.value;
      final totalLiters = dayData.fold<double>(
        0,
        (s, r) => s + ((r['total_volume'] ?? 0) as num).toDouble(),
      );
      return WaterDay(date: e.key, totalLiters: totalLiters);
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalLiters);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return WaterWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }
}
