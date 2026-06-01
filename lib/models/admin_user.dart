class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final DateTime? createdAt;
  final int totalPoints;
  final int currentLevel;
  final int currentStreak;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.avatar,
    this.createdAt,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.currentStreak = 0,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      totalPoints: int.tryParse(json['total_points']?.toString() ?? '0') ?? 0,
      currentLevel: int.tryParse(json['current_level']?.toString() ?? '1') ?? 1,
      currentStreak: int.tryParse(json['current_streak']?.toString() ?? '0') ?? 0,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  bool get isAdmin => role == 'admin';

  AdminUser copyWith({String? name, String? email, String? role}) {
    return AdminUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar,
      createdAt: createdAt,
      totalPoints: totalPoints,
      currentLevel: currentLevel,
      currentStreak: currentStreak,
    );
  }
}
