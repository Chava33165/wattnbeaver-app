import 'dart:async';
import '../../providers/dashboard_provider.dart';
import 'mqtt_service.dart';

/// Bridges incoming MQTT messages to the relevant providers.
class MqttHandler {
  final MqttService _service;
  final DashboardProvider _dashboard;
  StreamSubscription<RealtimeMessage>? _subscription;

  MqttHandler({
    required MqttService service,
    required DashboardProvider dashboard,
  })  : _service = service,
        _dashboard = dashboard;

  Future<void> start() async {
    await _service.connect();
    _subscription = _service.messages.listen(_route);
  }

  void _route(RealtimeMessage msg) {
    final topic = msg.topic;
    final data = msg.payload;

    if (topic.startsWith('wattnbeaber/energy/')) {
      final power = (data['power'] as num?)?.toDouble() ?? 0.0;
      _dashboard.updateEnergyFromMqtt(power);
    } else if (topic.startsWith('wattnbeaber/water/')) {
      final flow = (data['flow'] as num?)?.toDouble() ?? 0.0;
      _dashboard.updateWaterFromMqtt(flow);
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _service.dispose();
  }
}
