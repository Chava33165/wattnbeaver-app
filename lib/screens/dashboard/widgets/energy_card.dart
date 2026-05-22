import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/energy_summary.dart';
import '../../../models/energy_week.dart';
import '../../../models/gamification.dart';
import '../../../widgets/charts/flame_widget.dart';

class EnergyCard extends StatelessWidget {
  final EnergySummary? summary;
  final EnergyWeek? energyWeek;
  final Gamification? gamification;
  final VoidCallback? onTap;

  const EnergyCard({
    super.key,
    this.summary,
    this.energyWeek,
    this.gamification,
    this.onTap,
  });

  Map<int, double> _weekdayMap() {
    final map = <int, double>{};
    for (final d in energyWeek?.days ?? []) {
      final dt = DateTime.tryParse(d.date);
      if (dt != null) map[dt.weekday - 1] = d.totalKwh;
    }
    return map;
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('¿Qué significa la racha?',
            style: AppTextStyles.title3.copyWith(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Días consecutivos con medición de energía.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              color: const Color(0xFFFFD600),
              label: '1–3 días',
              desc: '¡Buen comienzo!',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              color: const Color(0xFFFF5E00),
              label: '4–6 días',
              desc: '¡Vas muy bien!',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              color: const Color(0xFF9B44D6),
              label: '7+ días',
              desc: '¡Leyenda!',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido',
                style: TextStyle(color: AppColors.mentaOscuro)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalKwh = summary?.totalKwh ?? 0.0;
    final double avgPower = summary?.avgPower ?? 0.0;
    final double changePercent = summary?.changePercent ?? 0.0;
    final bool isDown = changePercent <= 0;

    // Muestra watts si el kWh del día es 0 pero hay potencia activa
    final bool showWatts = totalKwh < 0.001 && avgPower > 0;

    final weekdayMap = _weekdayMap();
    final avg = energyWeek?.weekAvg ?? 0.0;
    final efficiencyStreak = calcFlameStreak(weekdayMap, avg);
    final int streak = gamification?.currentStreak ?? efficiencyStreak;

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
                        showWatts
                            ? avgPower.toStringAsFixed(0)
                            : totalKwh.toStringAsFixed(2),
                        style: AppTextStyles.display(context),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          showWatts ? 'W' : 'kWh',
                          style: AppTextStyles.muted(context),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    showWatts ? 'Potencia actual' : 'Consumo eléctrico hoy',
                    style: AppTextStyles.muted(context),
                  ),
                  const SizedBox(height: 6),
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
                  if (summary != null && !showWatts)
                    Row(
                      children: [
                        Icon(Icons.attach_money_rounded,
                            size: 13,
                            color:
                                AppColors.mentaOscuro.withValues(alpha: 0.7)),
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

            // ── Derecha: icono + racha ──
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Racha',
                      style: AppTextStyles.muted(context).copyWith(fontSize: 9),
                    ),
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: () => _showInfo(context),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
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

class _InfoRow extends StatelessWidget {
  final Color color;
  final String label;
  final String desc;

  const _InfoRow(
      {required this.color, required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label — $desc',
          style: AppTextStyles.chip(context)
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
