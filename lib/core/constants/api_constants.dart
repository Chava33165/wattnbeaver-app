class ApiConstants {
  static const String baseUrl = 'http://100.69.129.83:3000/api/v1';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Devices (general)
  static const String devices = '/devices';
  static const String devicesLink = '/devices/link';
  static String device(String id) => '/devices/$id';

  // Energy
  static const String energyTotal = '/energy/total';
  static const String energyHistory = '/energy/history';
  static const String energyDevices = '/energy/devices';
  static String energyDevice(String id) => '/energy/devices/$id';
  static String energyControl(String id) => '/energy/devices/$id/control';

  // Water
  static const String waterTotal = '/water/total';
  static const String waterHistory = '/water/history';
  static const String waterSensors = '/water/sensors';

  // Alerts
  static const String alerts = '/alerts';
  static String acknowledgeAlert(String id) => '/alerts/$id/acknowledge';
  static String resolveAlert(String id) => '/alerts/$id/resolve';

  // Gamification
  static const String gamificationProfile = '/gamification/profile';
  static const String gamificationStats = '/gamification/stats';
  static const String achievements = '/gamification/achievements';
  static const String challenges = '/gamification/challenges';
  static const String challengesStart = '/gamification/challenges/start';
  static const String leaderboard = '/gamification/leaderboard';
}
