class EnergyReading {
  final int id;
  final double power;
  final double voltage;
  final double current;
  final double energy;
  final DateTime timestamp;

  EnergyReading({
    required this.id,
    required this.power,
    required this.voltage,
    required this.current,
    required this.energy,
    required this.timestamp,
  });

  factory EnergyReading.fromJson(Map<String, dynamic> json) {
    return EnergyReading(
      id: json['id'] ?? 0,
      power: (json['power'] ?? 0).toDouble(),
      voltage: (json['voltage'] ?? 0).toDouble(),
      current: (json['current'] ?? 0).toDouble(),
      energy: (json['energy'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
