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

  // Vista 'day': un punto por hora, date = ISO completo del punto.
  // Procesa {data: [{hour, avg_flow, total_volume}]}
  factory WaterWeek.fromHourly(Map<String, dynamic> json) {
    final hourlyData = json['data'] as List? ?? [];

    final days = hourlyData.map((item) {
      final hour = item['hour'] as String? ?? '';
      final totalLiters = ((item['total_volume'] ?? 0) as num).toDouble();
      return WaterDay(date: hour, totalLiters: totalLiters);
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalLiters);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return WaterWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }

  // Vista 'week'/'month': agrupa datos horarios por fecha.
  // Procesa {data: [{hour, avg_flow, total_volume}]}
  factory WaterWeek.fromGroupedByDay(Map<String, dynamic> json) {
    final hourlyData = json['data'] as List? ?? [];

    final Map<String, double> byDay = {};
    for (final item in hourlyData) {
      final hour = item['hour'] as String? ?? '';
      final date = hour.length >= 10 ? hour.substring(0, 10) : hour;
      byDay[date] = (byDay[date] ?? 0.0) +
          ((item['total_volume'] ?? 0) as num).toDouble();
    }

    final days = byDay.entries
        .map((e) => WaterDay(date: e.key, totalLiters: e.value))
        .toList();
    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalLiters);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return WaterWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }

  // Vista 'year': agrupa getWeeklyStats por mes (año-mes).
  // Procesa {data: [{fecha, consumo_dia_litros, ...}]}
  factory WaterWeek.fromGroupedByMonth(Map<String, dynamic> json) {
    final rows = json['data'] as List? ?? [];

    final Map<String, double> byMonth = {};
    for (final r in rows) {
      final date = r['fecha'] as String? ?? '';
      final monthKey = date.length >= 7 ? date.substring(0, 7) : date;
      final liters = (r['consumo_dia_litros'] as num?)?.toDouble() ?? 0.0;
      byMonth[monthKey] = (byMonth[monthKey] ?? 0.0) + liters;
    }

    final days = byMonth.entries
        .map((e) => WaterDay(date: e.key, totalLiters: e.value))
        .toList();
    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalLiters);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return WaterWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }

  // json is the inner data object: {data: [{hour, avg_flow, total_volume}]}
  factory WaterWeek.fromJson(Map<String, dynamic> json) {
    final hourlyData = json['data'] as List? ?? [];

    final Map<String, List<dynamic>> byDay = {};
    for (final item in hourlyData) {
      final hour = item['hour'] as String? ?? '';
      final date = hour.length >= 10 ? hour.substring(0, 10) : hour;
      byDay.putIfAbsent(date, () => []).add(item);
    }

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
