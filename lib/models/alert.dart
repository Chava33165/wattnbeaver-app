class Alert {
  final String id;
  final String type;
  final String severity;
  final String message;
  final String? deviceId;
  final Map<String, dynamic> data;
  final bool acknowledged;
  final DateTime createdAt;

  Alert({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    this.deviceId,
    this.data = const {},
    this.acknowledged = false,
    required this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'info',
      message: json['message'] ?? '',
      deviceId: json['device_id']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? json['data']
          : {},
      acknowledged: json['acknowledged'] ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isCritical => severity == 'critical';
  bool get isWarning => severity == 'warning';
  bool get isInfo => severity == 'info';
}
