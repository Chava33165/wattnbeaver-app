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

  // Umbrales reales del backend: lv1=0, lv2=100, lv3=300, lv4=600...
  static const List<int> _thresholds = [
    0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500
  ];

  double get progressToNextLevel {
    if (currentLevel >= 10) return 1.0;
    final int start = _thresholds[(currentLevel - 1).clamp(0, 9)];
    final int end   = _thresholds[currentLevel.clamp(0, 9)];
    if (end <= start) return 1.0;
    return ((totalPoints - start) / (end - start)).clamp(0.0, 1.0);
  }

  int get pointsToNextLevel {
    if (currentLevel >= 10) return 0;
    return (_thresholds[currentLevel.clamp(0, 9)] - totalPoints).clamp(0, 999999);
  }
}
