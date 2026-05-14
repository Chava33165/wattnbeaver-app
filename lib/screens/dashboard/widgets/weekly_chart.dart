import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/energy_week.dart';
import '../../../models/water_week.dart';

class WeeklyChart extends StatelessWidget {
  final EnergyWeek? energyWeek;
  final WaterWeek? waterWeek;

  const WeeklyChart({super.key, this.energyWeek, this.waterWeek});

  static const _dayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  DateTime _monday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  double _avg(List<double> values) {
    final nonZero = values.where((v) => v > 0).toList();
    if (nonZero.isEmpty) return 0;
    return nonZero.reduce((a, b) => a + b) / nonZero.length;
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: AppColors.mentaMedio, size: 20),
            const SizedBox(width: 8),
            Text('¿Cómo leer la gráfica?',
                style: AppTextStyles.title(context)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('📊', 'Cada barra = consumo de ese día en la semana.', context),
            const SizedBox(height: 10),
            _infoRow('- - -', 'La línea punteada es tu promedio semanal.', context),
            const SizedBox(height: 10),
            _infoRow('↓', 'Barra por debajo de la línea → consumiste menos de lo normal. ¡Bien!', context),
            const SizedBox(height: 10),
            _infoRow('↑', 'Barra por encima de la línea → consumiste más de lo habitual.', context),
            const SizedBox(height: 10),
            _infoRow('👆', 'Toca cualquier barra para ver el valor exacto y una evaluación.', context),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido',
                style: AppTextStyles.chip(context)
                    .copyWith(color: AppColors.mentaOscuro)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String emoji, String text, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTextStyles.muted(context)),
        ),
      ],
    );
  }

  String _assessment(double val, double avg) {
    if (avg == 0 || val == 0) return 'Sin lecturas';
    if (val <= avg * 0.85) return '↓ Bajo el promedio — buen día';
    if (val <= avg * 1.3) return '→ Cerca del promedio';
    return '↑ Supera el promedio';
  }

  @override
  Widget build(BuildContext context) {
    final monday = _monday();

    // Mapear weekday (0=Lun) → valor
    final energyMap = <int, double>{};
    for (final d in energyWeek?.days ?? []) {
      energyMap[DateTime.parse(d.date).weekday - 1] = d.totalKwh;
    }

    final waterMap = <int, double>{};
    for (final d in waterWeek?.days ?? []) {
      waterMap[DateTime.parse(d.date).weekday - 1] = d.totalLiters;
    }

    final bool hasAnyData = energyMap.isNotEmpty || waterMap.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título + botón info ──
          Row(
            children: [
              Text('Esta semana', style: AppTextStyles.title(context)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showInfo(context),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.tierra.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Toca una barra para ver el detalle',
            style: AppTextStyles.muted(context).copyWith(fontSize: 10),
          ),
          const SizedBox(height: 16),

          if (!hasAnyData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Sin datos esta semana',
                    style: AppTextStyles.muted(context)),
              ),
            )
          else ...[
            // ── Gráfica Electricidad ──
            if (energyMap.isNotEmpty)
              _MiniChart(
                label: 'Electricidad',
                icon: Icons.bolt,
                domainColor: AppColors.mentaMedio,
                unit: 'kWh',
                dataMap: energyMap,
                monday: monday,
                showDateLabels: waterMap.isEmpty,
                assessment: _assessment,
                avg: _avg(energyMap.values.toList()),
                todayIndex: monday.weekday <= DateTime.now().weekday
                    ? DateTime.now().weekday - 1
                    : -1,
              ),

            if (energyMap.isNotEmpty && waterMap.isNotEmpty)
              const SizedBox(height: 12),

            // ── Gráfica Agua ──
            if (waterMap.isNotEmpty)
              _MiniChart(
                label: 'Agua',
                icon: Icons.water_drop,
                domainColor: AppColors.cieloMedio,
                unit: 'L',
                dataMap: waterMap,
                monday: monday,
                showDateLabels: true,
                assessment: _assessment,
                avg: _avg(waterMap.values.toList()),
                todayIndex: monday.weekday <= DateTime.now().weekday
                    ? DateTime.now().weekday - 1
                    : -1,
              ),
          ],
        ],
      ),
    );
  }
}

// ── Widget interno: una mini gráfica de barras con línea de promedio ──
class _MiniChart extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color domainColor;
  final String unit;
  final Map<int, double> dataMap;
  final DateTime monday;
  final bool showDateLabels;
  final String Function(double val, double avg) assessment;
  final double avg;
  final int todayIndex;

  const _MiniChart({
    required this.label,
    required this.icon,
    required this.domainColor,
    required this.unit,
    required this.dataMap,
    required this.monday,
    required this.showDateLabels,
    required this.assessment,
    required this.avg,
    required this.todayIndex,
  });

  Color _barColor(double val) {
    if (val == 0) return domainColor.withValues(alpha: 0.12);
    if (avg == 0) return domainColor;
    if (val > avg * 1.25) return AppColors.coralIntenso;
    return domainColor;
  }

  double _maxY() {
    if (dataMap.isEmpty) return 10;
    final max = dataMap.values.reduce((a, b) => a > b ? a : b);
    return (max * 1.4).ceilToDouble().clamp(1.0, 99999.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double maxY = _maxY();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Etiqueta de dominio ──
        Row(
          children: [
            Icon(icon, size: 13, color: domainColor),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.muted(context)
                    .copyWith(color: domainColor, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (avg > 0) ...[
              Container(
                width: 14,
                height: 1.5,
                decoration: BoxDecoration(
                  color: domainColor.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 4),
              Text('Promedio ${avg.toStringAsFixed(1)} $unit',
                  style: AppTextStyles.muted(context).copyWith(fontSize: 9)),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // ── Gráfica ──
        SizedBox(
          height: showDateLabels ? 120 : 100,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: isDark
                      ? Colors.black.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.92),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date =
                        monday.add(Duration(days: group.x));
                    final dayName = WeeklyChart._dayLetters[group.x];
                    final val = rod.toY;
                    final why = assessment(val, avg);
                    return BarTooltipItem(
                      '$dayName ${date.day}: ${val.toStringAsFixed(1)} $unit\n',
                      AppTextStyles.chip(context)
                          .copyWith(color: domainColor, fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                          text: why,
                          style: AppTextStyles.muted(context)
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: showDateLabels,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showDateLabels,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      final date = monday.add(Duration(days: index));
                      final bool isToday = index == todayIndex;
                      return SizedBox(
                        height: 28,
                        child: Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              WeeklyChart._dayLetters[index],
                              style: AppTextStyles.muted(context).copyWith(
                                fontSize: 10,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: isToday ? domainColor : null,
                              ),
                            ),
                            Text(
                              '${date.day}',
                              style: AppTextStyles.muted(context).copyWith(
                                fontSize: 8,
                                color: isToday ? domainColor : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              // ── Línea de promedio ──
              extraLinesData: avg > 0
                  ? ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: avg,
                          color: domainColor.withValues(alpha: 0.45),
                          strokeWidth: 1.5,
                          dashArray: [5, 4],
                        ),
                      ],
                    )
                  : null,
              barGroups: List.generate(7, (i) {
                final val = dataMap[i] ?? 0.0;
                final bool isToday = i == todayIndex;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: val,
                      color: _barColor(val),
                      width: isToday ? 17 : 13,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5)),
                      borderSide: isToday && val > 0
                          ? BorderSide(
                              color: _barColor(val).withValues(alpha: 0.5),
                              width: 1.5,
                            )
                          : BorderSide.none,
                    ),
                  ],
                );
              }),
            ),
            swapAnimationCurve: Curves.easeOut,
            swapAnimationDuration: const Duration(milliseconds: 700),
          ),
        ),
      ],
    );
  }
}
