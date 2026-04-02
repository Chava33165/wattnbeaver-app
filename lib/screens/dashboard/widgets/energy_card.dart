import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/energy_summary.dart';

class EnergyCard extends StatelessWidget {
  final EnergySummary? summary;
  final VoidCallback? onTap;

  const EnergyCard({super.key, this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double totalKwh = summary?.totalKwh ?? 12.5;
    final double changePercent = summary?.changePercent ?? -8.3;
    final bool isDown = changePercent <= 0;

    final List<FlSpot> spots = [
      const FlSpot(0, 3),
      const FlSpot(1, 2.5),
      const FlSpot(2, 4),
      const FlSpot(3, 3.5),
      const FlSpot(4, 5),
      const FlSpot(5, 4.5),
      const FlSpot(6, 6),
    ];

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        accent: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: valor + icono ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ── Icono ──
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.mentaMedio.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt,
                          color: AppColors.mentaMedio, size: 22),
                    ),
                    const SizedBox(height: 8),
                    // ── Badge % cambio ──
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
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── LineChart ──
            SizedBox(
              height: 72,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: AppColors.cardElectrica,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.mentaMedio.withValues(alpha: 0.3),
                            AppColors.mentaOscuro.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.85),
                      getTooltipItems: (touchedSpots) => touchedSpots
                          .map((spot) => LineTooltipItem(
                                '${spot.y} kWh',
                                AppTextStyles.chip(context)
                                    .copyWith(color: AppColors.mentaMedio),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
              ),
            ),

            // ── Footer: costo estimado ──
            if (summary != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.attach_money_rounded,
                      size: 13,
                      color: AppColors.mentaOscuro.withValues(alpha: 0.7)),
                  Text(
                    'Costo aprox. \$${(totalKwh * 2.5).toStringAsFixed(0)} MXN',
                    style: AppTextStyles.chip(context)
                        .copyWith(color: AppColors.mentaOscuro),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
