import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/water_summary.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterCard extends StatelessWidget {
  final WaterSummary? summary;
  final VoidCallback? onTap;

  const WaterCard({super.key, this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Datos simulados para LineChart
    final List<FlSpot> spots = [
      const FlSpot(0, 150),
      const FlSpot(1, 140),
      const FlSpot(2, 160),
      const FlSpot(3, 145),
      const FlSpot(4, 180),
      const FlSpot(5, 170),
      const FlSpot(6, 195),
    ];

    double totalLiters = summary?.totalLiters ?? 185.0;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        accent: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      child: Text(
                        'L',
                        style: AppTextStyles.muted(context),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cieloMedio.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: AppColors.cieloMedio,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Consumo hídrico hoy',
              style: AppTextStyles.muted(context),
            ),
            const SizedBox(height: 20),
            // LineChart embebido
            SizedBox(
              height: 80,
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
                      gradient: AppColors.cardHidrica,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.cieloMedio.withValues(alpha: 0.25),
                            AppColors.cieloClaro.withValues(alpha: 0.0),
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
                          : Colors.white.withValues(alpha: 0.8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots
                            .map((spot) => LineTooltipItem(
                                  '${spot.y} L',
                                  AppTextStyles.chip(context)
                                      .copyWith(color: AppColors.cieloMedio),
                                ))
                            .toList();
                      },
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
