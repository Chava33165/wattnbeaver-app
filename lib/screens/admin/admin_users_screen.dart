import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/admin_user.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/cards/stat_card.dart';

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
      body: _buildBody(context, provider),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarColor.withValues(alpha: 0.15),
              child: Text(
                user.initials,
                style: TextStyle(
                  color: avatarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(user.name,
                            style: AppTextStyles.bodyMedium,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      _RoleBadge(isAdmin: user.isAdmin),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: AppTextStyles.caption1
                          .copyWith(color: AppColors.textTertiary),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_outline, size: 12, color: AppColors.gamificationPurple),
                      const SizedBox(width: 2),
                      Text('${user.totalPoints} pts',
                          style: AppTextStyles.caption1
                              .copyWith(color: AppColors.gamificationPurple)),
                      const SizedBox(width: 12),
                      Icon(Icons.trending_up, size: 12, color: AppColors.energyPrimary),
                      const SizedBox(width: 2),
                      Text('Nv. ${user.currentLevel}',
                          style: AppTextStyles.caption1
                              .copyWith(color: AppColors.energyPrimary)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textTertiary, size: 20),
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
