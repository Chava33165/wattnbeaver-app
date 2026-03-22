import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class DeviceApi {
  static Future<Map<String, dynamic>> getDevices({String? type}) async {
    return ApiService.get(
      ApiConstants.devices,
      queryParams: type != null ? {'type': type} : null,
    );
  }

  static Future<Map<String, dynamic>> getDevice(String id) async {
    return ApiService.get(ApiConstants.device(id));
  }

  static Future<Map<String, dynamic>> linkDevice(
    Map<String, dynamic> body,
  ) async {
    return ApiService.post(ApiConstants.devicesLink, body);
  }

  static Future<Map<String, dynamic>> updateDevice(
    String id,
    Map<String, dynamic> body,
  ) async {
    return ApiService.put(ApiConstants.device(id), body);
  }

  static Future<Map<String, dynamic>> deleteDevice(String id) async {
    return ApiService.delete(ApiConstants.device(id));
  }

  static Future<Map<String, dynamic>> rotateApiKey(String id) async {
    return ApiService.post('${ApiConstants.device(id)}/rotate-key', {});
  }
}
