import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/stat_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Panel de Administración', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTextStyles.bodyMedium,
          tabs: const [
            Tab(text: 'Estadísticas'),
            Tab(text: 'Servidor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StatsTab(),
          _ServerTab(),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    if (provider.isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.statsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.statsError!, style: AppTextStyles.body),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<AdminProvider>().loadStats(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final s = provider.stats;
    if (s == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().loadStats(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel(context, 'USUARIOS'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _statTile('Total', '${s.totalUsers}', AppColors.gamificationPurple)),
              const SizedBox(width: 8),
              Expanded(child: _statTile('Rachas activas', '${s.activeStreaks}', AppColors.accentOrange)),
            ],
          ),
          const SizedBox(height: 16),
          _sectionLabel(context, 'LECTURAS'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _statTile('Energía', '${s.totalEnergyReadings}', AppColors.energyPrimary)),
              const SizedBox(width: 8),
              Expanded(child: _statTile('Agua', '${s.totalWaterReadings}', AppColors.waterPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          _sectionLabel(context, 'GAMIFICACIÓN'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _statTile('Puntos totales', '${s.totalPointsAwarded}', AppColors.gamificationPurple)),
              const SizedBox(width: 8),
              Expanded(child: _statTile('Prom/usuario', s.avgPointsPerUser.toStringAsFixed(1), AppColors.energyPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          _sectionLabel(context, 'ALERTAS'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _statTile('Total', '${s.totalAlerts}', AppColors.alertRed)),
              const SizedBox(width: 8),
              Expanded(child: _statTile('Dispositivos', '${s.totalDevices}', AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: AppTextStyles.caption1.copyWith(
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextStyles.statNumber.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.caption1
                  .copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _ServerTab extends StatelessWidget {
  const _ServerTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    if (provider.isLoadingServer) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.serverError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.serverError!, style: AppTextStyles.body),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<AdminProvider>().loadServerHealth(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final h = provider.serverHealth;
    if (h == null) return const SizedBox.shrink();

    final memPercent = h.memory.usagePercent / 100;
    final memColor = h.memory.usagePercent > 80 ? AppColors.alertRed : AppColors.energyPrimary;

    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().loadServerHealth(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Memoria RAM', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: memPercent.clamp(0.0, 1.0),
                  backgroundColor: AppColors.textTertiary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(memColor),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${h.memory.usedMb.toStringAsFixed(0)} MB usados',
                      style: AppTextStyles.caption1
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      '${h.memory.usagePercent.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption1.copyWith(color: memColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${h.memory.totalMb.toStringAsFixed(0)} MB',
                  style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          StatCard(
            child: Column(
              children: [
                _infoRow('Temperatura CPU',
                    h.cpuTempCelsius != null
                        ? '${h.cpuTempCelsius!.toStringAsFixed(1)} °C'
                        : 'N/A'),
                const Divider(height: 24),
                _infoRow('Uptime', h.uptimeFormatted),
                const Divider(height: 24),
                _infoRow('Plataforma', h.platform),
                const Divider(height: 24),
                _infoRow('Node.js', h.nodeVersion),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
