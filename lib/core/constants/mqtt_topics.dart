class MqttTopics {
  static String energyCurrent(String userId) =>
      'wattnbeaber/energy/$userId/current';

  static String waterCurrent(String userId) =>
      'wattnbeaber/water/$userId/current';

  static String alerts(String userId) => 'wattnbeaber/alerts/$userId';

  static const String deviceStatus = 'wattnbeaber/devices/+/status';
}
