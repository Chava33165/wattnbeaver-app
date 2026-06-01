import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/stat_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gamProvider = context.read<GamificationProvider>();
      if (gamProvider.profile == null) {
        gamProvider.loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final gamProvider = context.watch<GamificationProvider>();
    final user = authProvider.user;
    final profile = gamProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Perfil', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAvatarSection(user?.name ?? 'Usuario', user?.email ?? ''),
            const SizedBox(height: 20),
            if (profile != null) ...[
              _buildGamificationStats(profile),
              const SizedBox(height: 16),
            ],
            StatCard(
              child: Column(
                children: [
                  if (authProvider.isAdmin) ...[
                    _menuItem(
                      Icons.admin_panel_settings_outlined,
                      'Panel de Administración',
                      () => Navigator.pushNamed(context, AppRoutes.admin),
                      color: AppColors.mentaOscuro,
                    ),
                    const Divider(height: 1),
                  ],
                  _menuItem(Icons.person_outline, 'Editar perfil', () {}),
                  const Divider(height: 1),
                  _menuItem(Icons.notifications_outlined, 'Notificaciones',
                      () => Navigator.pushNamed(context, AppRoutes.settings)),
                  const Divider(height: 1),
                  _menuItem(Icons.help_outline, 'Ayuda', () {}),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context, authProvider),
                icon: const Icon(Icons.logout, color: AppColors.alertRed),
                label: Text(
                  'Cerrar sesion',
                  style: TextStyle(color: AppColors.alertRed),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.alertRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(String name, String email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.gamificationPurple.withValues(alpha: 0.15),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.gamificationPurple),
          ),
        ),
        const SizedBox(height: 12),
        Text(name, style: AppTextStyles.title2),
        const SizedBox(height: 4),
        Text(email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            )),
      ],
    );
  }

  Widget _buildGamificationStats(dynamic profile) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            child: Column(
              children: [
                Text('${profile.totalPoints}',
                    style: AppTextStyles.statNumber
                        .copyWith(color: AppColors.gamificationPurple)),
                Text('Puntos',
                    style: AppTextStyles.caption1
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            child: Column(
              children: [
                Text('${profile.currentLevel}',
                    style: AppTextStyles.statNumber
                        .copyWith(color: AppColors.energyPrimary)),
                Text('Nivel',
                    style: AppTextStyles.caption1
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            child: Column(
              children: [
                Text('${profile.currentStreak}',
                    style: AppTextStyles.statNumber
                        .copyWith(color: AppColors.accentOrange)),
                Text('Racha',
                    style: AppTextStyles.caption1
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.body.copyWith(color: color)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textTertiary, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cerrar sesion', style: AppTextStyles.title3),
        content: Text('Seguro que deseas cerrar sesion?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text('Cerrar sesion', style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false);
      }
    }
  }
}
