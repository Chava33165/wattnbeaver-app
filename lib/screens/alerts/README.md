# screens/alerts/

Centro de notificaciones del sistema. Lista todas las alertas generadas por los dispositivos ESP32 y permite reconocerlas.

## Severidades

| Nivel | Color | Cuándo ocurre |
|-------|-------|--------------|
| `critical` | Rojo `#FF6B4A` | Consumo extremo, sensor sin señal, dispositivo offline |
| `warning` | Naranja `#FF8F5E` | Consumo elevado, flujo anormal |
| `info` | Azul `#4AB8E0` | Dispositivo reconectado, lectura restablecida |

## Interfaz

- Chips de filtro en la parte superior: **Todas / Críticas / Advertencias / Info**
- `ListView` de cards, cada una con:
  - Ícono de severidad (coloreado)
  - Mensaje de alerta
  - Nombre del dispositivo que la generó
  - Tiempo relativo (`"hace 5 minutos"` via `timeago`)
  - Botón **Reconocer** (solo si `acknowledged == false`)
- Contador de alertas no leídas en el tab del dashboard

## Carga y reconocimiento

```dart
alertsProvider.loadAlerts()  // GET /alerts?acknowledged=false&limit=50
alertsProvider.acknowledge(id)  // POST /alerts/:id/acknowledge
```

Al reconocer, la card desaparece de la lista (el provider actualiza localmente antes de que llegue la confirmación del backend para respuesta inmediata).

> **Dato curioso:** las alertas las genera el backend automáticamente cuando detecta anomalías en los datos que llegan vía MQTT — la app solo las muestra, no tiene lógica de detección propia.
