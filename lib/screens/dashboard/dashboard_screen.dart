import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/mqtt/mqtt_handler.dart';
import '../../services/mqtt/mqtt_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../energy/energy_screen.dart';
import '../water/water_screen.dart';
import '../devices/devices_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/energy_card.dart';
import 'widgets/water_card.dart';
import 'widgets/weekly_chart.dart';
import 'widgets/device_quick_access.dart';
import 'widgets/gamification_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  MqttHandler? _mqttHandler;

  final List<Widget> _screens = const [
    _DashboardHome(),
    EnergyScreen(),
    WaterScreen(),
    DevicesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mqttHandler = MqttHandler(
        service: MqttService(),
        dashboard: context.read<DashboardProvider>(),
      );
      _mqttHandler!.start();
    });
  }

  @override
  void dispose() {
    _mqttHandler?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            activeIcon: Icon(Icons.bolt),
            label: 'Energia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined),
            activeIcon: Icon(Icons.water_drop),
            label: 'Agua',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_outlined),
            activeIcon: Icon(Icons.devices),
            label: 'Dispositivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SafeArea(
      child: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          if (dashboard.isLoading) {
            return const LoadingIndicator();
          }

          if (dashboard.error != null) {
            return ErrorDisplay(
              message: dashboard.error!,
              onRetry: () => dashboard.loadDashboard(),
            );
          }

          return RefreshIndicator(
            color: AppColors.energyPrimary,
            onRefresh: () => dashboard.loadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            AppColors.energyPrimary.withValues(alpha: 0.15),
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: AppTextStyles.title3.copyWith(
                            color: AppColors.energyPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormatter.greeting()},',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            Text(
                              user?.name ?? 'Usuario',
                              style: AppTextStyles.title3,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.alerts);
                        },
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined),
                            if (dashboard.recentAlerts.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.alertRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Energy & Water summary cards
                  Row(
                    children: [
                      EnergyCard(
                        summary: dashboard.energySummary,
                        onTap: () {
                          // Switch to energy tab
                        },
                      ),
                      const SizedBox(width: 12),
                      WaterCard(
                        summary: dashboard.waterSummary,
                        onTap: () {
                          // Switch to water tab
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Weekly chart
                  WeeklyChart(
                    energyWeek: dashboard.energyWeek,
                    waterWeek: dashboard.waterWeek,
                  ),
                  const SizedBox(height: 24),

                  // Devices quick access
                  if (dashboard.devices.isNotEmpty) ...[
                    _sectionHeader(AppStrings.yourDevices),
                    const SizedBox(height: 12),
                    DeviceQuickAccess(devices: dashboard.devices),
                    const SizedBox(height: 24),
                  ],

                  // Gamification
                  GamificationWidget(gamification: dashboard.gamification),
                  const SizedBox(height: 24),

                  // Recent alerts
                  if (dashboard.recentAlerts.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(child: _sectionHeader(AppStrings.recentAlerts)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.alerts);
                          },
                          child: const Text(AppStrings.viewAll),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...dashboard.recentAlerts.map((alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(
                                  color: alert.isCritical
                                      ? AppColors.alertRed
                                      : alert.isWarning
                                          ? AppColors.accentOrange
                                          : AppColors.waterPrimary,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  alert.isCritical
                                      ? Icons.error
                                      : alert.isWarning
                                          ? Icons.warning_amber
                                          : Icons.info_outline,
                                  color: alert.isCritical
                                      ? AppColors.alertRed
                                      : alert.isWarning
                                          ? AppColors.accentOrange
                                          : AppColors.waterPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    alert.message,
                                    style: AppTextStyles.bodyMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.caption1.copyWith(
        color: AppColors.textTertiary,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
