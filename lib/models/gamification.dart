// Real API profile: {id, user_id, total_points, current_level, current_streak, best_streak, last_activity_date, rank}
class Gamification {
  final String userId;
  final int totalPoints;
  final int currentLevel;
  final int currentStreak;
  final int bestStreak;
  final String? lastActivityDate;
  final int rank;

  Gamification({
    required this.userId,
    required this.totalPoints,
    required this.currentLevel,
    required this.currentStreak,
    required this.bestStreak,
    this.lastActivityDate,
    this.rank = 0,
  });

  factory Gamification.fromJson(Map<String, dynamic> json) {
    return Gamification(
      userId: json['user_id']?.toString() ?? '',
      totalPoints: json['total_points'] ?? 0,
      currentLevel: json['current_level'] ?? 1,
      currentStreak: json['current_streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      lastActivityDate: json['last_activity_date']?.toString(),
      rank: json['rank'] ?? 0,
    );
  }

  double get progressToNextLevel => (totalPoints % 500) / 500;
  int get pointsToNextLevel => 500 - (totalPoints % 500);
}
