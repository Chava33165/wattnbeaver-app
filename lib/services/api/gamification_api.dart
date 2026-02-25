import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class GamificationApi {
  static Future<Map<String, dynamic>> getProfile() async {
    return ApiService.get(ApiConstants.gamificationProfile);
  }

  static Future<Map<String, dynamic>> getStats() async {
    return ApiService.get(ApiConstants.gamificationStats);
  }

  static Future<Map<String, dynamic>> getAchievements() async {
    return ApiService.get(ApiConstants.achievements);
  }

  static Future<Map<String, dynamic>> getChallenges() async {
    return ApiService.get(ApiConstants.challenges);
  }

  static Future<Map<String, dynamic>> startChallenge(int challengeId) async {
    return ApiService.post(
      ApiConstants.challengesStart,
      {'challenge_id': challengeId},
    );
  }

  static Future<Map<String, dynamic>> getLeaderboard({int limit = 10}) async {
    return ApiService.get(
      ApiConstants.leaderboard,
      queryParams: {'limit': limit.toString()},
    );
  }
}
