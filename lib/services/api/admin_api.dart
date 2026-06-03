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
    // POST alternativo para bypass de Cloudflare WAF (bloquea PUT)
    return ApiService.post(ApiConstants.adminUserUpdate(id), body);
  }

  static Future<Map<String, dynamic>> deleteUser(String id) async {
    // POST alternativo para bypass de Cloudflare WAF (bloquea DELETE)
    return ApiService.post(ApiConstants.adminUserDelete(id), {});
  }

  static Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> body,
  ) async {
    return ApiService.post(ApiConstants.adminUsers, body);
  }

  static Future<Map<String, dynamic>> getStats() async {
    return ApiService.get(ApiConstants.adminStats);
  }

  static Future<Map<String, dynamic>> getServerHealth() async {
    return ApiService.get(ApiConstants.adminServer);
  }
}
