class NumberFormatter {
  static String kwh(double value) => '${value.toStringAsFixed(1)} kWh';

  static String watts(double value) => '${value.toStringAsFixed(0)} W';

  static String liters(double value) => '${value.toStringAsFixed(0)} L';

  static String percent(double value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}%';
  }

  static String peso(double value) => '\$${value.toStringAsFixed(2)}';

  static String points(int value) => value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
