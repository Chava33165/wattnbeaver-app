import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/devices/devices_screen.dart';
import '../screens/devices/add_device_screen.dart';
import '../screens/devices/provision_device_screen.dart';
import '../screens/devices/device_detail_screen.dart';
import '../screens/energy/energy_screen.dart';
import '../screens/water/water_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/gamification/gamification_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.devices:
        return MaterialPageRoute(builder: (_) => const DevicesScreen());
      case AppRoutes.addDevice:
        return MaterialPageRoute(builder: (_) => const AddDeviceScreen());
      case AppRoutes.provisionDevice:
        return MaterialPageRoute(builder: (_) => const ProvisionDeviceScreen());
      case AppRoutes.deviceDetail:
        return MaterialPageRoute(
          builder: (_) => const DeviceDetailScreen(),
          settings: settings,
        );
      case AppRoutes.energyDetail:
        return MaterialPageRoute(builder: (_) => const EnergyScreen());
      case AppRoutes.waterDetail:
        return MaterialPageRoute(builder: (_) => const WaterScreen());
      case AppRoutes.alerts:
        return MaterialPageRoute(builder: (_) => const AlertsScreen());
      case AppRoutes.gamification:
        return MaterialPageRoute(builder: (_) => const GamificationScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
