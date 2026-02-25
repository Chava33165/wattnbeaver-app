class DeviceReading {
  final double power;
  final double voltage;
  final double current;
  final DateTime? timestamp;

  DeviceReading({
    required this.power,
    required this.voltage,
    required this.current,
    this.timestamp,
  });

  factory DeviceReading.fromJson(Map<String, dynamic> json) {
    return DeviceReading(
      power: (json['power'] ?? 0).toDouble(),
      voltage: (json['voltage'] ?? 0).toDouble(),
      current: (json['current'] ?? 0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
    );
  }
}

class Device {
  final String id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String location;
  final String status;
  final DeviceReading? currentReading;
  final DateTime? createdAt;

  Device({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.location = '',
    this.status = 'active',
    this.currentReading,
    this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString() ?? '',
      deviceId: json['device_id'] ?? '',
      deviceName: json['device_name'] ?? '',
      deviceType: json['device_type'] ?? 'energy',
      location: json['location'] ?? '',
      status: json['status'] ?? 'active',
      currentReading: json['current_reading'] != null
          ? DeviceReading.fromJson(json['current_reading'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType,
      'location': location,
    };
  }

  bool get isOnline => status == 'active';
  bool get isEnergy => deviceType == 'energy';
  bool get isWater => deviceType == 'water';

  Device copyWith({String? status}) {
    return Device(
      id: id,
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: deviceType,
      location: location,
      status: status ?? this.status,
      currentReading: currentReading,
      createdAt: createdAt,
    );
  }
}
