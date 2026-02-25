import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/achievement.dart';
import '../../../widgets/cards/stat_card.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      child: Row(
        children: [
          // Status icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _statusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: achievement.icon.isNotEmpty
                  ? Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 24),
                    )
                  : Icon(_statusIcon(), color: _statusColor(), size: 24),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: achievement.isLocked
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (achievement.isInProgress) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progress / 100,
                      backgroundColor:
                          AppColors.waterPrimary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.waterPrimary,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.progress}%',
                    style: AppTextStyles.caption2.copyWith(
                      color: AppColors.waterPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (achievement.isCompleted && achievement.completedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormatter.formatDate(achievement.completedAt!),
                      style: AppTextStyles.caption2.copyWith(
                        color: AppColors.energyPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Points
          Column(
            children: [
              if (achievement.isCompleted)
                const Icon(Icons.check_circle,
                    color: AppColors.energyPrimary, size: 20),
              if (achievement.isLocked)
                const Icon(Icons.lock, color: AppColors.textTertiary, size: 20),
              const SizedBox(height: 4),
              Text(
                '${achievement.points}',
                style: AppTextStyles.caption1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gamificationPurple,
                ),
              ),
              Text(
                'pts',
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

  Color _statusColor() {
    if (achievement.isCompleted) return AppColors.energyPrimary;
    if (achievement.isInProgress) return AppColors.waterPrimary;
    return AppColors.textTertiary;
  }

  IconData _statusIcon() {
    if (achievement.isCompleted) return Icons.emoji_events;
    if (achievement.isInProgress) return Icons.hourglass_bottom;
    return Icons.lock;
  }
}
