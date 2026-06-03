import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/admin_user.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/stat_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AdminProvider>();
      p.loadAll();
      p.loadUsers();
    });
  }

  Future<void> _refresh() async {
    final p = context.read<AdminProvider>();
    await Future.wait([p.loadAll(), p.loadUsers()]);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cerrar sesión', style: AppTextStyles.title3),
        content: Text('¿Seguro que deseas cerrar sesión?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cerrar sesión', style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Panel Admin', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outlined),
            tooltip: 'Usuarios',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.adminUsers)
                .then((_) { if (context.mounted) context.read<AdminProvider>().loadUsers(); }),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Actualizar',
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _AdminHeader(user: auth.user),
            const SizedBox(height: 20),
            _QuickStats(),
            const SizedBox(height: 20),
            _SectionLabel('SERVIDOR'),
            const SizedBox(height: 8),
            _ServerCards(),
            const SizedBox(height: 20),
            _SectionLabel('ESTADÍSTICAS DEL SISTEMA'),
            const SizedBox(height: 8),
            _SystemStatsGrid(),
            const SizedBox(height: 20),
            _SectionLabel('USUARIOS RECIENTES'),
            const SizedBox(height: 8),
            _UsersPreview(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: AppColors.alertRed),
                label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.alertRed)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.alertRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AdminHeader extends StatelessWidget {
  final dynamic user;
  const _AdminHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Administrador';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.mentaOscuro.withValues(alpha: 0.15),
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.mentaOscuro,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: AppTextStyles.title2),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(email,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.mentaOscuro.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.mentaOscuro.withValues(alpha: 0.4)),
              ),
              child: Text(
                'ADMIN',
                style: TextStyle(
                  color: AppColors.mentaOscuro,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Quick stats row ─────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    final s = p.stats;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              children: [
                Text(
                  s != null ? '${s.totalUsers}' : '–',
                  style: AppTextStyles.statNumber.copyWith(color: AppColors.gamificationPurple),
                ),
                const SizedBox(height: 4),
                Text('Usuarios',
                    style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              children: [
                Text(
                  s != null ? '${s.totalDevices}' : '–',
                  style: AppTextStyles.statNumber.copyWith(color: AppColors.waterPrimary),
                ),
                const SizedBox(height: 4),
                Text('Dispositivos',
                    style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              children: [
                Text(
                  s != null ? '${s.totalAlerts}' : '–',
                  style: AppTextStyles.statNumber.copyWith(color: AppColors.alertRed),
                ),
                const SizedBox(height: 4),
                Text('Alertas',
                    style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Servidor ────────────────────────────────────────────────────────────────

class _ServerCards extends StatelessWidget {
  const _ServerCards();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();

    if (p.isLoadingServer) {
      return const StatCard(
        child: Center(child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      );
    }

    if (p.serverError != null) {
      return StatCard(
        child: _ErrorContent(
          message: p.serverError!,
          onRetry: () => context.read<AdminProvider>().loadServerHealth(),
        ),
      );
    }

    final h = p.serverHealth;
    if (h == null) return const SizedBox.shrink();

    final temp        = h.effectiveCpuTemp;
    final ramColor    = h.memory.usagePercent >= 80 ? AppColors.alertRed : AppColors.energyPrimary;
    final tempColor   = temp == null
        ? AppColors.textTertiary
        : temp >= 80 ? AppColors.alertRed
        : temp >= 60 ? AppColors.accentOrange
        : AppColors.energyPrimary;
    final tempLabel   = temp == null ? 'Sin datos'
        : temp >= 80 ? 'CRÍTICA'
        : temp >= 60 ? 'CALIENTE'
        : 'NORMAL';

    return Column(
      children: [
        // ── Hero row: RAM + Temperatura ──────────────────────────────
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // RAM
              Expanded(
                child: StatCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.memory_outlined, color: ramColor, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        '${h.memory.usagePercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: ramColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RAM',
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (h.memory.usagePercent / 100).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: AppColors.textTertiary.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(ramColor),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${h.memory.usedMb.toStringAsFixed(0)} / ${h.memory.totalMb.toStringAsFixed(0)} MB',
                        style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Temperatura
              Expanded(
                child: StatCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.thermostat_outlined, color: tempColor, size: 26),
                      const SizedBox(height: 6),
                      Text(
                        temp != null ? '${temp.toStringAsFixed(1)}°' : '–',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: tempColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TEMP CPU',
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tempColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tempColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          tempLabel,
                          style: TextStyle(
                            color: tempColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Almacenamiento (justo debajo del hero row)
        const SizedBox(height: 8),
        StatCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: h.disks.isEmpty
              ? Row(
                  children: [
                    Icon(Icons.storage_outlined, size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Sin datos de almacenamiento',
                          style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary)),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: h.disks.asMap().entries.map((e) {
                    final disk = e.value;
                    final diskColor = disk.usagePercent >= 80
                        ? AppColors.alertRed
                        : AppColors.accentOrange;
                    return Padding(
                      padding: EdgeInsets.only(top: e.key > 0 ? 12 : 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.storage_outlined, size: 16, color: diskColor),
                              const SizedBox(width: 6),
                              Text(disk.mountpoint, style: AppTextStyles.bodyMedium),
                              const Spacer(),
                              Text(
                                '${disk.usedGb.toStringAsFixed(1)} GB usados',
                                style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _ProgressBar(percent: disk.usagePercent, color: diskColor),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${disk.freeGb.toStringAsFixed(1)} GB disponibles',
                                style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
                              ),
                              Text(
                                '${disk.usagePercent.toStringAsFixed(1)}% de ${disk.totalGb.toStringAsFixed(1)} GB',
                                style: AppTextStyles.caption1.copyWith(
                                  color: diskColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        // CPU
        if (h.cpu != null) ...[
          const SizedBox(height: 8),
          StatCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardTitle(Icons.developer_board_outlined, 'CPU'),
                const SizedBox(height: 12),
                _ProgressBar(
                  percent: h.cpu!.loadPercent1m,
                  color: h.cpu!.loadPercent1m >= 80 ? AppColors.alertRed : AppColors.waterPrimary,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Carga ${h.cpu!.loadAvg1m.toStringAsFixed(2)} · ${h.cpu!.loadAvg5m.toStringAsFixed(2)} · ${h.cpu!.loadAvg15m.toStringAsFixed(2)}',
                      style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
                    ),
                    Text(
                      '${h.cpu!.loadPercent1m.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption1.copyWith(
                        color: h.cpu!.loadPercent1m >= 80 ? AppColors.alertRed : AppColors.waterPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (h.cpu!.model != null) ...[
                  const SizedBox(height: 4),
                  _InfoRow(Icons.memory_outlined, 'Modelo', h.cpu!.model!),
                ],
                const SizedBox(height: 4),
                _InfoRow(Icons.widgets_outlined, 'Núcleos', '${h.cpu!.cores}'),
              ],
            ),
          ),
        ],
        // Info general
        const SizedBox(height: 8),
        StatCard(
          child: Column(
            children: [
              _InfoRow(Icons.timer_outlined, 'Uptime', h.uptimeFormatted),
              const Divider(height: 20),
              _InfoRow(Icons.computer_outlined, 'Plataforma',
                  '${h.platform}${h.arch != null ? ' (${h.arch})' : ''}'),
              const Divider(height: 20),
              _InfoRow(Icons.code_outlined, 'Node.js', h.nodeVersion),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stats grid ──────────────────────────────────────────────────────────────

class _SystemStatsGrid extends StatelessWidget {
  const _SystemStatsGrid();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();

    if (p.isLoadingStats) {
      return const StatCard(
        child: Center(child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      );
    }

    if (p.statsError != null) {
      return StatCard(
        child: _ErrorContent(
          message: p.statsError!,
          onRetry: () => context.read<AdminProvider>().loadStats(),
        ),
      );
    }

    final s = p.stats;
    if (s == null) return const SizedBox.shrink();

    final items = [
      _StItem('Lecturas energía', '${s.totalEnergyReadings}', Icons.bolt_outlined, AppColors.energyPrimary),
      _StItem('Lecturas agua', '${s.totalWaterReadings}', Icons.water_drop_outlined, AppColors.waterPrimary),
      _StItem('Puntos otorgados', '${s.totalPointsAwarded}', Icons.star_outlined, AppColors.accentOrange),
      _StItem('Prom/usuario', s.avgPointsPerUser.toStringAsFixed(1), Icons.trending_up, AppColors.gamificationPurple),
      _StItem('Rachas activas', '${s.activeStreaks}', Icons.local_fire_department_outlined, AppColors.accentOrange),
    ];

    // Grid manual de 2 columnas para evitar problemas de constraint con GridView en ListView
    Widget statTile(_StItem item) => StatCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.value,
                    style: AppTextStyles.statNumber.copyWith(color: item.color, fontSize: 18)),
                Text(item.label,
                    style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );

    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: statTile(items[i])),
          if (i + 1 < items.length) ...[
            const SizedBox(width: 8),
            Expanded(child: statTile(items[i + 1])),
          ] else
            const Expanded(child: SizedBox.shrink()),
        ],
      ));
      if (i + 2 < items.length) rows.add(const SizedBox(height: 8));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

class _StItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StItem(this.label, this.value, this.icon, this.color);
}

// ─── Usuarios preview ────────────────────────────────────────────────────────

class _UsersPreview extends StatelessWidget {
  const _UsersPreview();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();

    if (p.isLoadingUsers) {
      return const StatCard(
        child: Center(child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 2),
        )),
      );
    }

    if (p.usersError != null) {
      return StatCard(
        child: _ErrorContent(
          message: p.usersError!,
          onRetry: () => context.read<AdminProvider>().loadUsers(),
        ),
      );
    }

    if (p.users.isEmpty) {
      return StatCard(
        child: Center(
          child: Text('Sin usuarios', style: AppTextStyles.body.copyWith(color: AppColors.textTertiary)),
        ),
      );
    }

    return StatCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ...p.users.take(5).toList().asMap().entries.map((e) {
            final isLast = e.key == (p.users.length.clamp(0, 5) - 1);
            return Column(
              children: [
                _UserTileSmall(
                  user: e.value,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.adminUserDetail,
                    arguments: e.value,
                  ).then((_) { if (context.mounted) context.read<AdminProvider>().loadUsers(); }),
                ),
                if (!isLast) const Divider(height: 1),
              ],
            );
          }),
          if (p.users.length > 5) ...[
            const Divider(height: 1),
            ListTile(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers)
                  .then((_) { if (context.mounted) context.read<AdminProvider>().loadUsers(); }),
              title: Text(
                'Ver ${p.users.length - 5} usuarios más',
                style: AppTextStyles.body.copyWith(color: AppColors.energyPrimary),
                textAlign: TextAlign.center,
              ),
              trailing: Icon(Icons.chevron_right, color: AppColors.energyPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserTileSmall extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;
  const _UserTileSmall({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = user.isAdmin ? AppColors.energyPrimary : AppColors.gamificationPurple;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withValues(alpha: 0.12),
        child: Text(user.initials,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(user.name, style: AppTextStyles.bodyMedium, overflow: TextOverflow.ellipsis),
          ),
          if (user.isAdmin) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.energyPrimary.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('admin',
                  style: TextStyle(color: AppColors.energyPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
      subtitle: Text(user.email,
          style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
          overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${user.totalPoints} pts',
              style: AppTextStyles.caption1.copyWith(color: AppColors.gamificationPurple, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            user.daysInactive >= 5
                ? '${user.daysInactive}d inactivo'
                : user.daysInactive >= 3
                    ? '${user.daysInactive}d inactivo'
                    : 'activo',
            style: AppTextStyles.caption1.copyWith(
              color: user.daysInactive >= 5
                  ? AppColors.alertRed
                  : user.daysInactive >= 3
                      ? AppColors.accentOrange
                      : AppColors.energyPrimary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets de apoyo ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption1.copyWith(
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CardTitle(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percent;
  final Color color;
  const _ProgressBar({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: (percent / 100).clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: AppColors.textTertiary.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorContent({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: AppColors.alertRed, size: 28),
        const SizedBox(height: 8),
        Text(message,
            style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}
