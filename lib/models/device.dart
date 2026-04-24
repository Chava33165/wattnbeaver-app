class DeviceReading {
  final double power;
  final double voltage;
  final double current;
  final double energy;  // kWh acumulado (sensores de energía)
  final double flow;    // L/min (sensores de agua)
  final double total;   // Volumen total L (sensores de agua)
  final DateTime? timestamp;

  DeviceReading({
    required this.power,
    required this.voltage,
    required this.current,
    this.energy = 0,
    this.flow = 0,
    this.total = 0,
    this.timestamp,
  });

  factory DeviceReading.fromJson(Map<String, dynamic> json) {
    double parseField(String key) =>
        double.tryParse(json[key]?.toString() ?? '0') ?? 0.0;
    return DeviceReading(
      power: parseField('power'),
      voltage: parseField('voltage'),
      current: parseField('current'),
      energy: parseField('energy'),
      flow: parseField('flow'),
      total: parseField('total'),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
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
  final String apiKey;
  final DeviceReading? currentReading;
  final DateTime? createdAt;

  Device({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.location = '',
    this.status = 'active',
    this.apiKey = '',
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
      apiKey: json['api_key']?.toString() ?? '',
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

  // Online = tiene lectura reciente (menos de 5 min) o al menos una lectura
  bool get isOnline => currentReading != null
      ? (currentReading!.timestamp == null ||
          DateTime.now().difference(currentReading!.timestamp!).inMinutes < 5)
      : false;
  bool get isEnergy => deviceType == 'energy';
  bool get isWater => deviceType == 'water';

  Device copyWith({String? status, String? apiKey}) {
    return Device(
      id: id,
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: deviceType,
      location: location,
      status: status ?? this.status,
      apiKey: apiKey ?? this.apiKey,
      currentReading: currentReading,
      createdAt: createdAt,
    );
  }
}
