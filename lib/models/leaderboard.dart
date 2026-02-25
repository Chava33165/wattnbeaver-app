// Real API leaderboard entry: {id, name, email, total_points, current_level, current_streak, best_streak, rank}
// my_rank is just a number (not an object)
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final int level;
  final int points;
  final int streak;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.level,
    required this.points,
    required this.streak,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['name'] ?? '',
      level: json['current_level'] ?? json['level'] ?? 1,
      points: json['total_points'] ?? json['points'] ?? 0,
      streak: json['current_streak'] ?? json['streak'] ?? 0,
    );
  }
}

class LeaderboardData {
  final List<LeaderboardEntry> leaderboard;
  final int? myRank;

  LeaderboardData({
    required this.leaderboard,
    this.myRank,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      leaderboard: (json['leaderboard'] as List? ?? [])
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
      myRank: json['my_rank'] is int ? json['my_rank'] : null,
    );
  }
}
