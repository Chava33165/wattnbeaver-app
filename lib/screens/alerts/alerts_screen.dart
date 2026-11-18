import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/alert.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/devices_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/stat_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertsProvider>().loadAlerts();
      context.read<DevicesProvider>().loadDevices();
      final gam = context.read<GamificationProvider>();
      if (gam.profile == null) gam.loadAll();
    });
  }

  // Genera alertas locales a partir de datos ya disponibles en providers
  List<Alert> _buildLocalAlerts(
      GamificationProvider gam, DevicesProvider devicesProvider) {
    final result = <Alert>[];
    final now = DateTime.now();

    // ── Dispositivos offline ──────────────────────────────────────────────
    for (final d in devicesProvider.devices.where((d) => !d.isOnline)) {
      result.add(Alert(
        id: 'local_offline_${d.deviceId}',
        type: 'system',
        severity: 'critical',
        message: '${d.deviceName} sin actividad ⚠️',
        deviceId: d.deviceId,
        createdAt: now,
      ));
    }

    // ── Logros completados ────────────────────────────────────────────────
    for (final a in gam.achievements.where((a) => a.isCompleted)) {
      result.add(Alert(
        id: 'local_achievement_${a.id}',
        type: 'gamification',
        severity: 'info',
        message: '¡Desbloqueaste "${a.name}"! +${a.points} pts 🏆',
        createdAt: a.completedAt ?? now,
      ));
    }

    // ── Mensajes motivadores por racha ────────────────────────────────────
    final streak = gam.profile?.currentStreak ?? 0;
    if (streak > 0) {
      const milestones = {
        1: '¡Buen inicio! Llevas 1 día monitoreando tu consumo 🌱',
        3: '¡3 días seguidos! Tu constancia marca la diferencia 💪',
        7: '¡Una semana completa de racha! Eres un crack 🔥',
        14: '¡Dos semanas de racha! Estás construyendo un hábito real ⚡',
        30: '¡30 días de racha! Leyenda del ahorro en WattBeaver 🏆',
      };
      if (milestones.containsKey(streak)) {
        result.add(Alert(
          id: 'local_streak_$streak',
          type: 'gamification',
          severity: 'info',
          message: milestones[streak]!,
          createdAt: now,
        ));
      } else if (streak > 1) {
        result.add(Alert(
          id: 'local_streak_active',
          type: 'gamification',
          severity: 'info',
          message: '¡Llevas $streak días de racha activos! Sigue así 🔥',
          createdAt: now,
        ));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Alertas', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
      ),
      body: Consumer3<AlertsProvider, GamificationProvider, DevicesProvider>(
        builder: (context, alertsProvider, gamProvider, devicesProvider, _) {
          if (alertsProvider.isLoading) return const LoadingIndicator();
          if (alertsProvider.error != null) {
            return ErrorDisplay(
              message: alertsProvider.error!,
              onRetry: alertsProvider.loadAlerts,
            );
          }

          final local = _buildLocalAlerts(gamProvider, devicesProvider);
          final server = alertsProvider.filteredAlerts;

          // Aplicar el mismo filtro de severidad a las alertas locales
          final filteredLocal = alertsProvider.filterSeverity == 'all'
              ? local
              : local
                  .where((a) => a.severity == alertsProvider.filterSeverity)
                  .toList();

          final combined = [...server, ...filteredLocal]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: () async {
              await alertsProvider.loadAlerts();
              await devicesProvider.loadDevices();
              if (gamProvider.profile == null) await gamProvider.loadAll();
            },
            color: AppColors.alertRed,
            child: Column(
              children: [
                _buildFilterChips(alertsProvider),
                Expanded(
                  child: combined.isEmpty
                      ? const EmptyState(
                          icon: Icons.notifications_none,
                          title: 'Sin alertas',
                          subtitle: 'No hay alertas para mostrar',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: combined.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final alert = combined[i];
                            return _AlertCard(
                              alert: alert,
                              onAcknowledge: alert.isLocal
                                  ? null
                                  : () => alertsProvider
                                      .acknowledgeAlert(alert.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(AlertsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('Todas', 'all', provider),
            const SizedBox(width: 8),
            _chip('Críticas', 'critical', provider),
            const SizedBox(width: 8),
            _chip('Advertencias', 'warning', provider),
            const SizedBox(width: 8),
            _chip('Info', 'info', provider),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String severity, AlertsProvider provider) {
    final selected = provider.filterSeverity == severity;
    final colors = {
      'critical': AppColors.alertRed,
      'warning': AppColors.accentOrange,
      'info': AppColors.waterPrimary,
      'all': AppColors.textSecondary,
    };
    final color = colors[severity] ?? AppColors.textSecondary;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => provider.setFilter(severity),
      selectedColor: color.withValues(alpha: 0.15),
      checkmarkColor: color,
      labelStyle: AppTextStyles.caption1.copyWith(
        color: selected ? color : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onAcknowledge;

  const _AlertCard({required this.alert, this.onAcknowledge});

  Color _severityColor() {
    if (alert.isCritical) return AppColors.alertRed;
    if (alert.isWarning) return AppColors.accentOrange;
    return AppColors.waterPrimary;
  }

  IconData _severityIcon() {
    if (alert.type == 'gamification') return Icons.emoji_events_rounded;
    if (alert.isCritical) return Icons.error;
    if (alert.isWarning) return Icons.warning_amber;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor();
    return Opacity(
      opacity: alert.acknowledged ? 0.6 : 1.0,
      child: StatCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Icon(_severityIcon(), color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormatter.timeAgo(alert.createdAt),
                        style: AppTextStyles.caption2.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (alert.deviceId != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${alert.deviceId}',
                          style: AppTextStyles.caption2.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!alert.acknowledged && onAcknowledge != null)
              TextButton(
                onPressed: onAcknowledge,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 32),
                ),
                child: Text(
                  'OK',
                  style: AppTextStyles.caption1.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
