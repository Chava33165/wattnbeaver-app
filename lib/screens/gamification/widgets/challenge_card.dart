import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/challenge.dart';
import '../../../widgets/cards/stat_card.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gamificationPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${challenge.rewardPoints} pts',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.gamificationPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: challenge.progressPercent,
              backgroundColor:
                  AppColors.gamificationPurple.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.gamificationPurple,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(challenge.progressPercent * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.gamificationPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${challenge.currentValue.toStringAsFixed(1)} / ${challenge.targetValue.toStringAsFixed(1)}',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${challenge.daysRemaining} dias restantes',
                style: AppTextStyles.caption2.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
