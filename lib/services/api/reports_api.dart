import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class ReportsApi {
  static Future<Map<String, dynamic>> getDaily({String? date}) async {
    return ApiService.get(
      ApiConstants.reportsDaily,
      queryParams: date != null ? {'date': date} : null,
    );
  }

  static Future<Map<String, dynamic>> getWeekly({String? weekStart}) async {
    return ApiService.get(
      ApiConstants.reportsWeekly,
      queryParams: weekStart != null ? {'week_start': weekStart} : null,
    );
  }

  static Future<Map<String, dynamic>> getMonthly({
    int? month,
    int? year,
  }) async {
    final params = <String, String>{};
    if (month != null) params['month'] = month.toString();
    if (year != null) params['year'] = year.toString();
    return ApiService.get(
      ApiConstants.reportsMonthly,
      queryParams: params.isEmpty ? null : params,
    );
  }
}
