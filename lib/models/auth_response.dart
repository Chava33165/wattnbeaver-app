import 'user.dart';

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AuthResponse(
      token: data['token'] ?? '',
      user: User.fromJson(data['user'] ?? data),
    );
  }
}
