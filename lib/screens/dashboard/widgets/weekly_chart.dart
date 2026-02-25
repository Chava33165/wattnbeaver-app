import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/energy_week.dart';
import '../../../models/water_week.dart';
import '../../../widgets/cards/stat_card.dart';

class WeeklyChart extends StatelessWidget {
  final EnergyWeek? energyWeek;
  final WaterWeek? waterWeek;

  const WeeklyChart({super.key, this.energyWeek, this.waterWeek});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTA SEMANA',
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          if (energyWeek != null)
            Text(
              '${energyWeek!.weekTotal.toStringAsFixed(1)} kWh total',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: _buildChart(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(AppColors.energyPrimary, 'Energia'),
              const SizedBox(width: 24),
              _legend(AppColors.waterPrimary, 'Agua'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final energyDays = energyWeek?.days ?? [];
    final waterDays = waterWeek?.days ?? [];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _maxY(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = rodIndex == 0 ? 'kWh' : 'L';
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} $label',
                AppTextStyles.caption2.copyWith(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    index < days.length ? days[index] : '',
                    style: AppTextStyles.caption2.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          final energyVal =
              i < energyDays.length ? energyDays[i].totalKwh : 0.0;
          final waterVal =
              i < waterDays.length ? waterDays[i].totalLiters / 100 : 0.0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: energyVal,
                color: AppColors.energyPrimary,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: waterVal,
                color: AppColors.waterPrimary,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  double _maxY() {
    double max = 10;
    if (energyWeek != null) {
      for (final day in energyWeek!.days) {
        if (day.totalKwh > max) max = day.totalKwh;
      }
    }
    if (waterWeek != null) {
      for (final day in waterWeek!.days) {
        if (day.totalLiters / 100 > max) max = day.totalLiters / 100;
      }
    }
    return max * 1.2;
  }
}
