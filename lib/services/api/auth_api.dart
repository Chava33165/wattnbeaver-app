import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return ApiService.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      auth: false,
    );
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    return ApiService.post(
      ApiConstants.register,
      {'name': name, 'email': email, 'password': password},
      auth: false,
    );
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return ApiService.get(ApiConstants.profile);
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    return ApiService.put(ApiConstants.profile, data);
  }
}
