// Real API history: {data: [{hour: "2024-01-01T00:00:00", avg_power: X, total_energy: X}]}
class EnergyDay {
  final String date;
  final double totalKwh;
  final double avgPower;

  EnergyDay({
    required this.date,
    required this.totalKwh,
    required this.avgPower,
  });
}

class EnergyWeek {
  final List<EnergyDay> days;
  final double weekTotal;
  final double weekAvg;

  EnergyWeek({
    required this.days,
    required this.weekTotal,
    required this.weekAvg,
  });

  // Agrupa entradas diarias por mes para la vista anual.
  // Input: {data: [{fecha: "YYYY-MM-DD", consumo_dia_kwh, potencia_promedio_w}]}
  // Output: una EnergyDay por mes (date = "YYYY-MM"), 12 slots.
  factory EnergyWeek.fromGroupedByMonth(Map<String, dynamic> json) {
    final rows = json['data'] as List? ?? [];

    final Map<String, double> kwhByMonth = {};
    final Map<String, double> powerSumByMonth = {};
    final Map<String, int> countByMonth = {};

    for (final r in rows) {
      final fecha = r['fecha'] as String? ?? '';
      final monthKey = fecha.length >= 7 ? fecha.substring(0, 7) : ''; // "YYYY-MM"
      if (monthKey.isEmpty) continue;
      final kwh = (r['consumo_dia_kwh'] as num?)?.toDouble() ?? 0.0;
      final power = (r['potencia_promedio_w'] as num?)?.toDouble() ?? 0.0;
      kwhByMonth[monthKey] = (kwhByMonth[monthKey] ?? 0.0) + kwh;
      powerSumByMonth[monthKey] = (powerSumByMonth[monthKey] ?? 0.0) + power;
      countByMonth[monthKey] = (countByMonth[monthKey] ?? 0) + 1;
    }

    final days = kwhByMonth.entries.map((e) {
      final count = countByMonth[e.key] ?? 1;
      return EnergyDay(
        date: e.key,
        totalKwh: e.value,
        avgPower: (powerSumByMonth[e.key] ?? 0.0) / count,
      );
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalKwh);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return EnergyWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }

  // Nuevo formato: {data: [{fecha, dia_semana, consumo_dia_kwh, potencia_promedio_w, ...}]}
  factory EnergyWeek.fromWeeklyStats(Map<String, dynamic> json) {
    final rows = json['data'] as List? ?? [];

    final days = rows.map((r) {
      final date = r['fecha'] as String? ?? '';
      final totalKwh =
          (r['consumo_dia_kwh'] as num?)?.toDouble() ?? 0.0;
      final avgPower =
          (r['potencia_promedio_w'] as num?)?.toDouble() ?? 0.0;
      return EnergyDay(date: date, totalKwh: totalKwh, avgPower: avgPower);
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalKwh);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return EnergyWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }

  // Formato horario: {data: [{hour: "ISO", avg_power, total_energy}]} — una entrada por hora
  // Usa total_energy (kWh calculado con tiempo real en el backend).
  factory EnergyWeek.fromHourly(Map<String, dynamic> json) {
    final hourlyData = json['data'] as List? ?? [];

    final days = hourlyData.map((r) {
      final hour = r['hour'] as String? ?? '';
      final avgPower = (r['avg_power'] as num?)?.toDouble() ?? 0.0;
      final totalKwh = (r['total_energy'] as num?)?.toDouble()
          ?? avgPower / 1000.0; // fallback si el campo no existe
      return EnergyDay(date: hour, totalKwh: totalKwh, avgPower: avgPower);
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalKwh);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return EnergyWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }

  // Agrupa entradas horarias por fecha para semana/mes.
  // Input: {data: [{hour: "ISO", avg_power, total_energy}]} (muchas entradas)
  // Output: una EnergyDay por fecha, con total_energy sumado.
  factory EnergyWeek.fromGroupedByDay(Map<String, dynamic> json) {
    final hourlyData = json['data'] as List? ?? [];

    final Map<String, double> kwhByDay = {};
    final Map<String, double> powerSumByDay = {};
    final Map<String, int> countByDay = {};

    for (final r in hourlyData) {
      final hour = r['hour'] as String? ?? '';
      final date = hour.length >= 10 ? hour.substring(0, 10) : hour;
      final avgPower = (r['avg_power'] as num?)?.toDouble() ?? 0.0;
      final totalEnergy = (r['total_energy'] as num?)?.toDouble()
          ?? avgPower / 1000.0;

      kwhByDay[date] = (kwhByDay[date] ?? 0.0) + totalEnergy;
      powerSumByDay[date] = (powerSumByDay[date] ?? 0.0) + avgPower;
      countByDay[date] = (countByDay[date] ?? 0) + 1;
    }

    final days = kwhByDay.entries.map((e) {
      final count = countByDay[e.key] ?? 1;
      return EnergyDay(
        date: e.key,
        totalKwh: e.value,
        avgPower: (powerSumByDay[e.key] ?? 0.0) / count,
      );
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalKwh);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return EnergyWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }

  // json is the inner data object: {data: [{hour, avg_power, total_energy}]}
  factory EnergyWeek.fromJson(Map<String, dynamic> json) {
    final hourlyData = json['data'] as List? ?? [];

    // Group by date (first 10 chars of hour string)
    final Map<String, List<dynamic>> byDay = {};
    for (final item in hourlyData) {
      final hour = item['hour'] as String? ?? '';
      final date = hour.length >= 10 ? hour.substring(0, 10) : hour;
      byDay.putIfAbsent(date, () => []).add(item);
    }

    // Create EnergyDay per date
    // NOTA: el campo total_energy del Sonoff POW tiene bug de firmware (valores acumulativos incorrectos).
    // Se usa avg_power × 1h / 1000 para calcular kWh, igual que el endpoint /statistics/weekly.
    final days = byDay.entries.map((e) {
      final dayData = e.value;
      // Cada registro = 1 hora → kWh = avg_power(W) × 1h / 1000
      final totalKwh = dayData.fold<double>(
        0,
        (s, r) => s + ((r['avg_power'] ?? 0) as num).toDouble() / 1000.0,
      );
      final avgPower = dayData.isEmpty
          ? 0.0
          : dayData.fold<double>(
                0,
                (s, r) => s + ((r['avg_power'] ?? 0) as num).toDouble(),
              ) /
              dayData.length;
      return EnergyDay(date: e.key, totalKwh: totalKwh, avgPower: avgPower);
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    final weekTotal = days.fold<double>(0, (s, d) => s + d.totalKwh);
    final weekAvg = days.isEmpty ? 0.0 : weekTotal / days.length;

    return EnergyWeek(days: days, weekTotal: weekTotal, weekAvg: weekAvg);
  }
}
