# core/constants/

Valores globales inmutables. Todo `static const`, nada de lógica.

## Archivos

### `app_colors.dart`
Paleta completa de la app organizada por familia semántica:
- **Menta** — identidad principal (energía): claro → medio → base → oscuro → profundo
- **Cielo** — agua: claro → medio → dark
- **Lavanda** — gamificación
- **Coral / Durazno** — alertas y acento naranja
- **Crema / Arena / Tierra / Café** — fondos y texto (tonos cálidos)

También expone gradientes pre-armados (`cardElectrica`, `cardHidrica`, `botonAccion`, etc.) para no repetir `LinearGradient` en cada widget.

### `api_constants.dart`
Base URL y todas las rutas REST como constantes estáticas. Los endpoints con parámetros dinámicos (ej. `/devices/:id`) usan métodos estáticos que reciben el id y devuelven el string:

```dart
static String device(String id) => '/devices/$id';
```

### `mqtt_topics.dart`
Genera los topics MQTT por usuario con el prefijo `wattnbeaber/` (typo heredado del firmware del ESP32 — se usa tal cual):

```dart
MqttTopics.energyCurrent(userId)  // → 'wattnbeaber/energy/{userId}/current'
MqttTopics.waterCurrent(userId)   // → 'wattnbeaber/water/{userId}/current'
```

### `app_strings.dart`
Todos los textos de la UI en español organizados por sección (auth, dashboard, dispositivos, gamificación…). Centralizar aquí facilita cualquier traducción futura.

> **Dato curioso:** el tagline oficial de la app está aquí: `"Monitorea, Ahorra, Gana"`.
