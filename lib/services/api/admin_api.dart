import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class AdminApi {
  static Future<Map<String, dynamic>> getUsers() async {
    return ApiService.get(ApiConstants.adminUsers);
  }

  static Future<Map<String, dynamic>> getUser(String id) async {
    return ApiService.get(ApiConstants.adminUser(id));
  }

  static Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> body,
  ) async {
    return ApiService.put(ApiConstants.adminUser(id), body);
  }

  static Future<Map<String, dynamic>> deleteUser(String id) async {
    return ApiService.delete(ApiConstants.adminUser(id));
  }

  static Future<Map<String, dynamic>> getStats() async {
    return ApiService.get(ApiConstants.adminStats);
  }

  static Future<Map<String, dynamic>> getServerHealth() async {
    return ApiService.get(ApiConstants.adminServer);
  }
}
