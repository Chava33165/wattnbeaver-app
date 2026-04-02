import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class EnergyApi {
  static Future<Map<String, dynamic>> getTotal() async {
    return ApiService.get(ApiConstants.energyTotal);
  }

  static Future<Map<String, dynamic>> getHistory({
    String period = 'week',
  }) async {
    return ApiService.get(
      ApiConstants.energyHistory,
      queryParams: {'period': period},
    );
  }

  static Future<Map<String, dynamic>> getWeeklyStats({
    required String startDate,
    required String endDate,
  }) async {
    return ApiService.get(
      ApiConstants.energyWeeklyStats,
      queryParams: {'startDate': startDate, 'endDate': endDate},
    );
  }

  static Future<Map<String, dynamic>> getDevices() async {
    return ApiService.get(ApiConstants.energyDevices);
  }

  static Future<Map<String, dynamic>> getDevice(String id) async {
    return ApiService.get(ApiConstants.energyDevice(id));
  }

  static Future<Map<String, dynamic>> controlDevice(
    String id,
    String action,
  ) async {
    return ApiService.post(ApiConstants.energyControl(id), {'action': action});
  }
}
