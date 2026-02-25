// Real API achievement: {id, name, description, icon, points, category, progress, completed (0/1), completed_at}
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int points;
  final String category;
  final String status;
  final int progress;
  final DateTime? completedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.icon = '',
    required this.points,
    this.category = '',
    required this.status,
    this.progress = 0,
    this.completedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    // Derive status from 'completed' (int 0/1) if 'status' field not present
    String status;
    if (json.containsKey('status') && json['status'] is String) {
      status = json['status'];
    } else {
      final completed = json['completed'];
      final progress = json['progress'] ?? 0;
      if (completed == 1 || completed == true) {
        status = 'completed';
      } else if ((progress as num) > 0) {
        status = 'in_progress';
      } else {
        status = 'locked';
      }
    }

    return Achievement(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      points: json['points'] ?? 0,
      category: json['category'] ?? '',
      status: status,
      progress: (json['progress'] ?? 0) as int,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isLocked => status == 'locked';
}
