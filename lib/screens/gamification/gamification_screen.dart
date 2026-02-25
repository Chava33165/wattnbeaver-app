import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/gamification_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/stat_card.dart';
import 'widgets/achievement_card.dart';
import 'widgets/challenge_card.dart';
import 'widgets/leaderboard_item.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamificationProvider>().loadAll();
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
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Gamificación', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gamificationPurple,
          labelColor: AppColors.gamificationPurple,
          unselectedLabelColor: AppColors.textTertiary,
          labelStyle: AppTextStyles.caption1.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Logros'),
            Tab(text: 'Retos'),
            Tab(text: 'Ranking'),
          ],
        ),
      ),
      body: Consumer<GamificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingIndicator();
          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: provider.loadAll,
            );
          }

          return Column(
            children: [
              if (provider.profile != null) _buildProfileBanner(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAchievementsTab(provider),
                    _buildChallengesTab(provider),
                    _buildLeaderboardTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileBanner(GamificationProvider provider) {
    final profile = provider.profile!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gamificationGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nivel ${profile.currentLevel}',
                style: AppTextStyles.title3.copyWith(color: Colors.white),
              ),
              Text(
                '${profile.totalPoints} pts',
                style: AppTextStyles.caption1.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const Spacer(),
          if (profile.currentStreak > 0)
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${profile.currentStreak} días',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          const SizedBox(width: 12),
          if (profile.rank > 0)
            Column(
              children: [
                Text(
                  '#${profile.rank}',
                  style: AppTextStyles.title2.copyWith(color: Colors.white),
                ),
                Text(
                  'Ranking',
                  style: AppTextStyles.caption2.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(GamificationProvider provider) {
    if (provider.achievements.isEmpty) {
      return const EmptyState(
        icon: Icons.emoji_events_outlined,
        title: 'Sin logros',
        subtitle: 'Completa actividades para desbloquear logros',
      );
    }
    return RefreshIndicator(
      onRefresh: provider.loadAll,
      color: AppColors.gamificationPurple,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.achievements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) =>
            AchievementCard(achievement: provider.achievements[i]),
      ),
    );
  }

  Widget _buildChallengesTab(GamificationProvider provider) {
    if (provider.activeChallenges.isEmpty) {
      return const EmptyState(
        icon: Icons.flag_outlined,
        title: 'Sin retos',
        subtitle: 'No hay retos disponibles en este momento',
      );
    }
    return RefreshIndicator(
      onRefresh: provider.loadAll,
      color: AppColors.gamificationPurple,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.activeChallenges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) =>
            ChallengeCard(challenge: provider.activeChallenges[i]),
      ),
    );
  }

  Widget _buildLeaderboardTab(GamificationProvider provider) {
    final lb = provider.leaderboard;
    if (lb == null || lb.leaderboard.isEmpty) {
      return const EmptyState(
        icon: Icons.leaderboard_outlined,
        title: 'Sin datos',
        subtitle: 'El ranking estará disponible pronto',
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadLeaderboard,
      color: AppColors.gamificationPurple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lb.leaderboard.length + (lb.myRank != null ? 1 : 0),
        itemBuilder: (context, i) {
          if (lb.myRank != null && i == lb.leaderboard.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: StatCard(
                child: Text(
                  'Tu posición: #${lb.myRank}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gamificationPurple,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LeaderboardItem(entry: lb.leaderboard[i]),
          );
        },
      ),
    );
  }
}
