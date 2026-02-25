import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/gamification.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/cards/stat_card.dart';

class GamificationWidget extends StatelessWidget {
  final Gamification? gamification;

  const GamificationWidget({super.key, this.gamification});

  @override
  Widget build(BuildContext context) {
    if (gamification == null) return const SizedBox.shrink();

    return StatCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.gamification),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.gamificationGradient,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${gamification!.currentLevel}',
                style: AppTextStyles.title2.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivel ${gamification!.currentLevel}',
                  style: AppTextStyles.title3.copyWith(
                    color: AppColors.gamificationPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${gamification!.totalPoints} puntos',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: gamification!.progressToNextLevel,
                    backgroundColor:
                        AppColors.gamificationPurple.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gamificationPurple,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${gamification!.pointsToNextLevel} pts para nivel ${gamification!.currentLevel + 1}',
                  style: AppTextStyles.caption2.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
