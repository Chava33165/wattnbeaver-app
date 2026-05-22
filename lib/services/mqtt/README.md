# services/mqtt/

Comunicación en tiempo real con el broker MQTT. Dos archivos con responsabilidades separadas.

## `mqtt_service.dart` — transporte

Maneja la conexión TCP al broker y expone un `Stream`:

```
Broker: 100.69.129.83:1883
Auth:   backend_user / backend_password
```

**Flujo de conexión:**
1. Crea `MqttServerClient` con `clientIdentifier` único
2. Se suscribe a `wattnbeaber/energy/#` y `wattnbeaber/water/#`
3. Expone `messageStream` como `Stream<RealtimeMessage>`

**`RealtimeMessage`:**
```dart
class RealtimeMessage {
  final String topic;    // 'wattnbeaber/energy/abc123/current'
  final Map<String, dynamic> payload;  // { power: 120.5, voltage: 120.0, ... }
}
```

## `mqtt_handler.dart` — lógica

Escucha el stream de `MqttService` y enruta cada mensaje al provider correcto:

```dart
stream.listen((msg) {
  if (msg.topic.contains('/energy/')) {
    dashboardProvider.updateEnergyFromMqtt(power, voltage, current);
  } else if (msg.topic.contains('/water/')) {
    dashboardProvider.updateWaterFromMqtt(flow, total);
  }
});
```

El handler vive en `DashboardProvider`, que lo inicializa al montar el dashboard.

> **Dato curioso:** el topic usa el wildcard `#` al final (`wattnbeaber/energy/#`) en lugar de suscribirse a un dispositivo específico. Esto permite recibir datos de **todos** los dispositivos del usuario en una sola suscripción.
