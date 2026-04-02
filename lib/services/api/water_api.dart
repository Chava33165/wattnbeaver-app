import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class WaterApi {
  static Future<Map<String, dynamic>> getTotal() async {
    return ApiService.get(ApiConstants.waterTotal);
  }

  static Future<Map<String, dynamic>> getHistory({
    String period = 'week',
  }) async {
    return ApiService.get(
      ApiConstants.waterHistory,
      queryParams: {'period': period},
    );
  }

  static Future<Map<String, dynamic>> getWeeklyStats({
    required String startDate,
    required String endDate,
  }) async {
    return ApiService.get(
      ApiConstants.waterWeeklyStats,
      queryParams: {'startDate': startDate, 'endDate': endDate},
    );
  }

  static Future<Map<String, dynamic>> getSensors() async {
    return ApiService.get(ApiConstants.waterSensors);
  }
}
