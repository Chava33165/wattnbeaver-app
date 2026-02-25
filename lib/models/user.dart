class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.avatar,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
