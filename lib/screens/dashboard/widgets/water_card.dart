import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../models/water_summary.dart';
import '../../../widgets/cards/stat_card.dart';
import '../../../widgets/charts/activity_ring.dart';

class WaterCard extends StatelessWidget {
  final WaterSummary? summary;
  final VoidCallback? onTap;

  const WaterCard({super.key, this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StatCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'AGUA',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.water_drop,
                  color: AppColors.waterPrimary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: ActivityRing(
                progress: summary != null
                    ? (summary!.totalLiters / 500).clamp(0.0, 1.0)
                    : 0,
                color: AppColors.waterPrimary,
                size: 72,
                strokeWidth: 7,
                child: Text(
                  summary != null
                      ? summary!.totalLiters.toStringAsFixed(0)
                      : '--',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.waterPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Litros hoy',
                style: AppTextStyles.caption2.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (summary != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: summary!.changePercent <= 0
                        ? AppColors.energyPrimary.withValues(alpha: 0.1)
                        : AppColors.alertRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    NumberFormatter.percent(summary!.changePercent),
                    style: AppTextStyles.caption1.copyWith(
                      color: summary!.changePercent <= 0
                          ? AppColors.energyDark
                          : AppColors.alertRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  '≈ ${NumberFormatter.peso(summary!.totalLiters * 0.05)}',
                  style: AppTextStyles.caption2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
