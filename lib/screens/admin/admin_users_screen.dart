import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/admin_user.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/common/custom_text_field.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Usuarios', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mentaOscuro,
        foregroundColor: Colors.white,
        tooltip: 'Crear admin',
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.person_add_outlined),
      ),
      body: _buildBody(context, provider),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Crear usuario admin', style: AppTextStyles.title3),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Nombre',
                  controller: nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Email',
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Contraseña',
                  controller: passCtrl,
                  obscureText: true,
                  validator: Validators.password,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            Consumer<AdminProvider>(
              builder: (_, p, __) => TextButton(
                onPressed: p.isOperating
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        final ok = await p.createUser({
                          'name': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim(),
                          'password': passCtrl.text,
                        });
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(ok ? 'Admin creado correctamente' : (p.operationError ?? 'Error')),
                          backgroundColor: ok ? AppColors.energyPrimary : AppColors.alertRed,
                        ));
                      },
                child: p.isOperating
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Crear', style: TextStyle(color: AppColors.mentaOscuro)),
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      emailCtrl.dispose();
      passCtrl.dispose();
    });
  }

  Widget _buildBody(BuildContext context, AdminProvider provider) {
    if (provider.isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.usersError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.usersError!, style: AppTextStyles.body),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<AdminProvider>().loadUsers(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.users.isEmpty) {
      return Center(
        child: Text('Sin usuarios', style: AppTextStyles.body.copyWith(color: AppColors.textTertiary)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().loadUsers(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final user = provider.users[index];
          final adminProvider = context.read<AdminProvider>();
          return _UserTile(
            user: user,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.adminUserDetail,
              arguments: user,
            ).then((_) => adminProvider.loadUsers()),
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarColor = user.isAdmin ? AppColors.energyPrimary : AppColors.gamificationPurple;

    return StatCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarColor.withValues(alpha: 0.15),
              child: Text(
                user.initials,
                style: TextStyle(
                  color: avatarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info central
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + rol
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: AppTextStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _RoleBadge(isAdmin: user.isAdmin),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Email
                  Text(
                    user.email,
                    style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Puntos y nivel
                  Row(
                    children: [
                      Icon(Icons.star_outline, size: 12, color: AppColors.gamificationPurple),
                      const SizedBox(width: 3),
                      Text(
                        '${user.totalPoints} pts',
                        style: AppTextStyles.caption1.copyWith(color: AppColors.gamificationPurple),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.bar_chart, size: 12, color: AppColors.energyPrimary),
                      const SizedBox(width: 3),
                      Text(
                        'Nivel ${user.currentLevel}',
                        style: AppTextStyles.caption1.copyWith(color: AppColors.energyPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Trailing: badge inactividad + flecha
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _InactivityBadge(days: user.daysInactive),
                const SizedBox(height: 6),
                Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isAdmin;
  const _RoleBadge({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final color = isAdmin ? AppColors.energyPrimary : AppColors.gamificationPurple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isAdmin ? 'admin' : 'user',
        style: AppTextStyles.caption1.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

class _InactivityBadge extends StatelessWidget {
  final int days;
  const _InactivityBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final IconData icon;

    if (days >= 5) {
      color = AppColors.alertRed;
      label = '$days días';
      icon = Icons.hourglass_empty;
    } else if (days >= 3) {
      color = AppColors.accentOrange;
      label = '$days días';
      icon = Icons.timelapse;
    } else {
      color = AppColors.energyPrimary;
      label = 'Activo';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
