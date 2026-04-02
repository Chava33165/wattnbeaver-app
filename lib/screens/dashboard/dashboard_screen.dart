import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/neu_glass.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/mqtt/mqtt_handler.dart';
import '../../services/mqtt/mqtt_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../core/widgets/neu_glass_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neu_button.dart';
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return NeuGlassScaffold(
      bottomNavigationBar: _buildNeuBottomBar(context, isDark),
      child: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }

  Widget _buildNeuBottomBar(BuildContext context, bool isDark) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_rounded, 0),
                _navItem(Icons.bolt_rounded, 1),
                _navItem(Icons.water_drop_rounded, 2),
                _navItem(Icons.devices_rounded, 3),
                _navItem(Icons.person_rounded, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isSelected = _currentIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.mentaMedio,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mentaMedio.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              )
            : const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white54 : AppColors.tierra),
          size: 24,
        ),
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

    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        if (dashboard.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (dashboard.error != null) {
          return ErrorDisplay(
            message: dashboard.error!,
            onRetry: () => dashboard.loadDashboard(),
          );
        }

        return RefreshIndicator(
          color: AppColors.mentaMedio,
          onRefresh: () => dashboard.loadDashboard(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // ── Header con saludo + avatar ──
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: NeuGlass.neuRaised(context, radius: 24),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : 'W',
                        style: AppTextStyles.title(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormatter.greeting()},',
                          style: AppTextStyles.muted(context),
                        ),
                        Text(
                          user?.name ?? 'Beaver',
                          style: AppTextStyles.title(context),
                        ),
                      ],
                    ),
                  ),
                  NeuButton(
                    radius: 24,
                    width: 48,
                    height: 48,
                    padding: EdgeInsets.zero,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.alerts),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.cafeOscuro,
                        ),
                        if (dashboard.recentAlerts.isNotEmpty)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.coralIntenso,
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

              // ── Métrica eléctrica principal ──
              EnergyCard(
                summary: dashboard.energySummary,
                onTap: () {},
              ),
              const SizedBox(height: 14),

              // ── Métrica hídrica principal ──
              WaterCard(
                summary: dashboard.waterSummary,
                onTap: () {},
              ),
              const SizedBox(height: 14),

              // ── Gráfico Semanal ──
              WeeklyChart(
                energyWeek: dashboard.energyWeek,
                waterWeek: dashboard.waterWeek,
              ),
              const SizedBox(height: 14),

              // ── Dispositivos ──
              if (dashboard.devices.isNotEmpty) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tus dispositivos',
                          style: AppTextStyles.title(context)),
                      const SizedBox(height: 16),
                      DeviceQuickAccess(devices: dashboard.devices),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Gamificación ──
              GamificationWidget(gamification: dashboard.gamification),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
