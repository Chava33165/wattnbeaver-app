import 'dart:convert';
import 'package:http/http.dart' as http;

class ProvisionService {
  static const String _baseUrl = 'http://192.168.4.1';
  static const Duration _timeout = Duration(seconds: 10);
  static const String _defaultServerUrl =
      'https://wattnbeaver-api.wattnbeaver.site/api/v1';

  // ─── YF-201 (ESP32 firmware custom) ──────────────────────────────────────────

  /// Obtiene información del dispositivo en modo AP.
  /// Devuelve {device_id, type, firmware} o lanza una excepción.
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/info'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['device_id'] == null) {
      throw Exception('Respuesta inválida del dispositivo');
    }
    return data;
  }

  /// Envía las credenciales WiFi y configuración HTTP al ESP32.
  /// Devuelve true si fue exitoso.
  static Future<bool> configureDevice({
    required String ssid,
    required String password,
    required String deviceId,
    required String apiKey,
    String serverUrl = _defaultServerUrl,
  }) async {
    final body = jsonEncode({
      'ssid': ssid,
      'password': password,
      'server_url': serverUrl,
      'device_id': deviceId,
      'api_key': apiKey,
    });

    final response = await http
        .post(
          Uri.parse('$_baseUrl/configure'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) return false;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['success'] == true;
  }

  // ─── Tasmota (Sonoff S31) ─────────────────────────────────────────────────────

  /// Detecta un dispositivo Tasmota en modo AP (192.168.4.1).
  /// Devuelve {device_id, type, firmware} o lanza excepción.
  static Future<Map<String, dynamic>> getTasmotaInfo() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/cm?cmnd=Status%200'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['Status'] == null) {
      throw Exception('Respuesta inválida del dispositivo');
    }

    final firmware =
        (data['StatusFWR'] as Map<String, dynamic>?)?['Version'] as String? ??
            '';

    final mac =
        (data['StatusNET'] as Map<String, dynamic>?)?['Mac'] as String? ?? '';
    final macBytes = mac.replaceAll(':', '').toLowerCase();
    final deviceId = macBytes.length >= 6
        ? 'tasmota_${macBytes.substring(macBytes.length - 6)}'
        : 'tasmota_${DateTime.now().millisecondsSinceEpoch.toRadixString(16).substring(0, 6)}';

    return {'device_id': deviceId, 'type': 'energy', 'firmware': firmware};
  }

  /// Configura un dispositivo Tasmota: sube Berry script y envía credenciales WiFi.
  /// Devuelve true si fue exitoso.
  static Future<bool> configureTasmota({
    required String ssid,
    required String password,
    required String deviceId,
    required String apiKey,
    String serverUrl = _defaultServerUrl,
  }) async {
    final url = '$serverUrl/ingest/energy';
    final apiKeyHeader = 'X-Device-Api-Key: $apiKey';

    // 1. Configurar Rule1 con WebQuery para enviar datos de energía
    // Almacena Power y Voltage en Var1/Var2, envía al llegar Current
    final rule = 'ON Tele-ENERGY#Power DO Var1 %value% ENDON '
        'ON Tele-ENERGY#Voltage DO Var2 %value% ENDON '
        'ON Tele-ENERGY#Today DO Var3 %value% ENDON '
        'ON Tele-ENERGY#Current DO '
        'WebQuery $url POST [Content-Type: application/json|$apiKeyHeader] '
        '{"device_id":"$deviceId","power":%Var1%,"voltage":%Var2%,"current":%value%,"energy":%Var3%} '
        'ENDON';

    final ruleResponse = await http
        .get(Uri.parse('$_baseUrl/cm?cmnd=${Uri.encodeComponent('Rule1 $rule')}'))
        .timeout(_timeout);
    if (ruleResponse.statusCode != 200) return false;

    // 2. Activar Rule1 + Teleperiod 30s
    await http
        .get(Uri.parse('$_baseUrl/cm?cmnd=Backlog%20Rule1%201%3B%20Teleperiod%2030'))
        .timeout(_timeout);

    // 3. Configurar módulo y PowerOnState SIN reiniciar (se guarda en flash)
    await http
        .get(Uri.parse('$_baseUrl/cm?cmnd=Backlog%20Module%2041%3B%20PowerOnState%201'))
        .timeout(_timeout);

    // Pequeña pausa para que Tasmota procese el cambio de módulo
    await Future.delayed(const Duration(milliseconds: 500));

    // 4. Configurar WiFi y reiniciar (en petición separada)
    final encodedSsid = Uri.encodeComponent(ssid);
    final encodedPass = Uri.encodeComponent(password);
    final wifiResponse = await http
        .get(Uri.parse(
            '$_baseUrl/cm?cmnd=Backlog%20SSId%20$encodedSsid%3B%20Password%20$encodedPass%3B%20Restart%201'))
        .timeout(_timeout);

    return wifiResponse.statusCode == 200;
  }
}
