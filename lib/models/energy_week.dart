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
    final days = byDay.entries.map((e) {
      final dayData = e.value;
      final totalKwh = dayData.fold<double>(
        0,
        (s, r) => s + ((r['total_energy'] ?? 0) as num).toDouble(),
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
