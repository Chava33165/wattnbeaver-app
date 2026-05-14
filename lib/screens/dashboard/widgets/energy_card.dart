import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/energy_summary.dart';
import '../../../models/energy_week.dart';
import '../../../widgets/charts/flame_widget.dart';

class EnergyCard extends StatelessWidget {
  final EnergySummary? summary;
  final EnergyWeek? energyWeek;
  final VoidCallback? onTap;

  const EnergyCard({super.key, this.summary, this.energyWeek, this.onTap});

  Map<int, double> _weekdayMap() {
    final map = <int, double>{};
    for (final d in energyWeek?.days ?? []) {
      final dt = DateTime.tryParse(d.date);
      if (dt != null) map[dt.weekday - 1] = d.totalKwh;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final double totalKwh = summary?.totalKwh ?? 0.0;
    final double changePercent = summary?.changePercent ?? 0.0;
    final bool isDown = changePercent <= 0;

    final weekdayMap = _weekdayMap();
    final avg = energyWeek?.weekAvg ?? 0.0;
    final streak = calcFlameStreak(weekdayMap, avg);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        accent: false,
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Izquierda: datos + flamita ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Número principal
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalKwh.toStringAsFixed(1),
                        style: AppTextStyles.display(context),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('kWh',
                            style: AppTextStyles.muted(context)),
                      ),
                    ],
                  ),
                  Text('Consumo eléctrico hoy',
                      style: AppTextStyles.muted(context)),
                  const SizedBox(height: 6),
                  // Badge % cambio
                  if (changePercent != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDown
                            ? AppColors.mentaMedio.withValues(alpha: 0.18)
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
                                ? AppColors.mentaOscuro
                                : AppColors.coralIntenso,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${changePercent.abs().toStringAsFixed(1)}%',
                            style: AppTextStyles.chip(context).copyWith(
                              color: isDown
                                  ? AppColors.mentaOscuro
                                  : AppColors.coralIntenso,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Costo estimado
                  if (summary != null)
                    Row(
                      children: [
                        Icon(Icons.attach_money_rounded,
                            size: 13,
                            color: AppColors.mentaOscuro
                                .withValues(alpha: 0.7)),
                        Text(
                          'Aprox. \$${(totalKwh * 2.5).toStringAsFixed(0)} MXN',
                          style: AppTextStyles.chip(context)
                              .copyWith(color: AppColors.mentaOscuro),
                        ),
                      ],
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
                    color: AppColors.mentaMedio.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt,
                      color: AppColors.mentaMedio, size: 18),
                ),
                const SizedBox(height: 10),
                // ── Racha label ──
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
