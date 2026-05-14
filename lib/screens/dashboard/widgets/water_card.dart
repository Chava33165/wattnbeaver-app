import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/water_summary.dart';
import '../../../models/water_week.dart';
import '../../../widgets/charts/flame_widget.dart';

class WaterCard extends StatelessWidget {
  final WaterSummary? summary;
  final WaterWeek? waterWeek;
  final VoidCallback? onTap;

  const WaterCard({super.key, this.summary, this.waterWeek, this.onTap});

  Map<int, double> _weekdayMap() {
    final map = <int, double>{};
    for (final d in waterWeek?.days ?? []) {
      final dt = DateTime.tryParse(d.date);
      if (dt != null) map[dt.weekday - 1] = d.totalLiters;
    }
    return map;
  }

  double _changePercent() {
    final today = summary?.totalLiters ?? 0;
    final avg = waterWeek?.weekAvg ?? 0;
    if (avg == 0 || today == 0) return 0;
    return ((today - avg) / avg) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final double totalLiters = summary?.totalLiters ?? 0.0;
    final double changePercent = _changePercent();
    final bool isDown = changePercent <= 0;

    final weekdayMap = _weekdayMap();
    final avg = waterWeek?.weekAvg ?? 0.0;
    final streak = calcFlameStreak(weekdayMap, avg);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        accent: false,
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Izquierda: datos ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalLiters.toStringAsFixed(0),
                        style: AppTextStyles.display(context),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('L',
                            style: AppTextStyles.muted(context)),
                      ),
                    ],
                  ),
                  Text('Consumo hídrico hoy',
                      style: AppTextStyles.muted(context)),
                  const SizedBox(height: 6),
                  // Badge % cambio vs promedio semana
                  if (waterWeek != null && waterWeek!.weekAvg > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDown
                            ? AppColors.cieloMedio.withValues(alpha: 0.18)
                            : AppColors.coralIntenso.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDown
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            size: 11,
                            color: isDown
                                ? AppColors.cieloMedio
                                : AppColors.coralIntenso,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${changePercent.abs().toStringAsFixed(1)}%',
                            style: AppTextStyles.chip(context).copyWith(
                              color: isDown
                                  ? AppColors.cieloMedio
                                  : AppColors.coralIntenso,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ── Derecha: flamita + icono ──
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.cieloMedio.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.water_drop,
                      color: AppColors.cieloMedio, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Racha',
                  style: AppTextStyles.muted(context)
                      .copyWith(fontSize: 9),
                ),
                const SizedBox(height: 4),
                FlameWidget(streak: streak, maxStreak: 7),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
