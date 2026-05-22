import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/gamification_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/charts/flame_widget.dart';
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

  String _streakMessage(int streak) {
    if (streak >= 100) return '🏅 ¡100+ días! Eres inspiración';
    if (streak >= 60)  return '👑 ¡2 meses! Leyenda absoluta';
    if (streak >= 30)  return '🏆 ¡Un mes entero! Campeón';
    if (streak >= 21)  return '💪 ¡3 semanas! Eres imparable';
    if (streak >= 14)  return '🔥 ¡2 semanas! Estás en fuego';
    if (streak >= 7)   return '⭐ ¡Una semana completa!';
    if (streak >= 3)   return '🌱 ¡$streak días seguidos!';
    if (streak == 2)   return '¡2 días! ¡Sigue así!';
    return '¡Primer día! ¡Buen comienzo!';
  }

  Widget _buildProfileBanner(GamificationProvider provider) {
    final profile = provider.profile!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gamificationGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.gamificationPurple.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Fila: nivel + puntos + rank ──
          Row(
            children: [
              // Badge nivel
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LVL',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${profile.currentLevel}',
                      style: AppTextStyles.title2.copyWith(
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.totalPoints} puntos',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (profile.currentLevel < 10)
                      Text(
                        '${profile.pointsToNextLevel} pts para nivel ${profile.currentLevel + 1}',
                        style: AppTextStyles.caption2.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                  ],
                ),
              ),
              if (profile.rank > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'RANK',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        '#${profile.rank}',
                        style: AppTextStyles.title3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Flamita central ──
          FlameWidget(
            streak: profile.currentStreak,
            maxStreak: 30,
          ),

          // ── Mensaje de racha ──
          const SizedBox(height: 6),
          Text(
            profile.currentStreak > 0
                ? _streakMessage(profile.currentStreak)
                : '¡Empieza tu racha hoy!',
            style: AppTextStyles.caption1.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),

          if (profile.bestStreak > 0) ...[
            const SizedBox(height: 2),
            Text(
              'Mejor racha: ${profile.bestStreak} días',
              style: AppTextStyles.caption2.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Barra de progreso ──
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: profile.progressToNextLevel,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${(profile.progressToNextLevel * 100).toInt()}% hacia nivel ${profile.currentLevel + 1}',
              style: AppTextStyles.caption2.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
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
