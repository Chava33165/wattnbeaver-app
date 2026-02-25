class Challenge {
  final String id;
  final String challengeId;
  final String name;
  final String type;
  final double currentValue;
  final double targetValue;
  final int rewardPoints;
  final String status;
  final String startDate;
  final String endDate;
  final int daysRemaining;

  Challenge({
    required this.id,
    required this.challengeId,
    required this.name,
    required this.type,
    required this.currentValue,
    required this.targetValue,
    required this.rewardPoints,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id']?.toString() ?? '',
      challengeId: json['challenge_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      currentValue: (json['current_value'] ?? 0).toDouble(),
      targetValue: (json['target_value'] ?? 1).toDouble(),
      rewardPoints: json['reward_points'] ?? 0,
      status: json['status'] ?? 'active',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }

  double get progressPercent =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0;
}
