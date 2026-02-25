import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class AlertsApi {
  static Future<Map<String, dynamic>> getAlerts({
    bool? acknowledged,
    int limit = 20,
  }) async {
    final params = <String, String>{'limit': limit.toString()};
    if (acknowledged != null) {
      params['acknowledged'] = acknowledged.toString();
    }
    return ApiService.get(ApiConstants.alerts, queryParams: params);
  }

  static Future<Map<String, dynamic>> acknowledgeAlert(String id) async {
    return ApiService.post(ApiConstants.acknowledgeAlert(id), {});
  }
}
