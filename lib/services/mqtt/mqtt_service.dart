import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class RealtimeMessage {
  final String topic;
  final Map<String, dynamic> payload;
  const RealtimeMessage({required this.topic, required this.payload});
}

class MqttService {
  static const String _broker = '100.69.129.83';
  static const int _port = 1883;
  static const String _username = 'backend_user';
  static const String _password = 'backend_password';

  MqttServerClient? _client;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final _controller = StreamController<RealtimeMessage>.broadcast();
  Stream<RealtimeMessage> get messages => _controller.stream;

  Future<bool> connect() async {
    if (_isConnected) return true;

    final clientId =
        'wattnbeaver-app-${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient.withPort(_broker, clientId, _port);
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 60;
    _client!.connectTimeoutPeriod = 10000;
    _client!.onDisconnected = _onDisconnected;

    final connMsg = MqttConnectMessage()
        .authenticateAs(_username, _password)
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMsg;

    try {
      await _client!.connect();
      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        _isConnected = true;
        _client!.subscribe('wattnbeaber/energy/#', MqttQos.atMostOnce);
        _client!.subscribe('wattnbeaber/water/#', MqttQos.atMostOnce);
        _client!.updates?.listen(_onMessages);
        return true;
      }
    } catch (_) {
      _client?.disconnect();
    }
    return false;
  }

  void _onDisconnected() {
    _isConnected = false;
  }

  void _onMessages(List<MqttReceivedMessage<MqttMessage?>> messages) {
    if (_controller.isClosed) return;
    for (final msg in messages) {
      try {
        final recMess = msg.payload as MqttPublishMessage;
        final raw = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message);
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _controller.add(RealtimeMessage(topic: msg.topic, payload: data));
      } catch (_) {}
    }
  }

  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    if (!_controller.isClosed) _controller.close();
  }
}
