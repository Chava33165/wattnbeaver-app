import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/gamification.dart';
import '../../../routes/app_routes.dart';

class GamificationWidget extends StatelessWidget {
  final Gamification? gamification;

  const GamificationWidget({super.key, this.gamification});

  @override
  Widget build(BuildContext context) {
    if (gamification == null) return const SizedBox.shrink();

    final int level = gamification!.currentLevel;
    final int points = gamification!.totalPoints;
    final int streak = gamification!.currentStreak;
    final double progress = gamification!.progressToNextLevel.clamp(0.0, 1.0);
    final int ptsNext = gamification!.pointsToNextLevel;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.gamification),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: badge de nivel + info + racha ──
            Row(
              children: [
                // Badge nivel con gradiente lavanda
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.gamificationGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lavandaMedio.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$level',
                      style: AppTextStyles.title(context,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info central
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nivel $level',
                        style: AppTextStyles.title(context,
                            color: AppColors.lavandaMedio),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$points puntos totales',
                        style: AppTextStyles.muted(context),
                      ),
                    ],
                  ),
                ),

                // Racha + flecha
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.duraznoMedio.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department,
                                size: 14, color: AppColors.duraznoMedio),
                            const SizedBox(width: 3),
                            Text(
                              '$streak días',
                              style: AppTextStyles.chip(context).copyWith(
                                color: AppColors.duraznoMedio,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.lavandaMedio.withValues(alpha: 0.7),
                        size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Barra de progreso al siguiente nivel ──
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor:
                    AppColors.lavandaMedio.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.lavandaMedio),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),

            // ── Label progreso ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}% hacia nivel ${level + 1}',
                  style: AppTextStyles.chip(context)
                      .copyWith(color: AppColors.lavandaMedio),
                ),
                Text(
                  '$ptsNext pts restantes',
                  style: AppTextStyles.chip(context)
                      .copyWith(color: AppColors.tierra),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
