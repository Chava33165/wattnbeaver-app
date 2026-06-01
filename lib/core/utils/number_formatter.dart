class NumberFormatter {
  static String kwh(double value) {
    if (value == 0) return '0.0 kWh';
    if (value < 0.1) return '${value.toStringAsFixed(3)} kWh';
    return '${value.toStringAsFixed(1)} kWh';
  }

  static String watts(double value) => '${value.toStringAsFixed(0)} W';

  static String liters(double value) {
    if (value == 0) return '0 L';
    if (value < 1) return '${(value * 1000).toStringAsFixed(0)} mL';
    return '${value.toStringAsFixed(1)} L';
  }

  static String percent(double value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}%';
  }

  static String peso(double value) => '\$${value.toStringAsFixed(2)}';

  static String points(int value) => value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
