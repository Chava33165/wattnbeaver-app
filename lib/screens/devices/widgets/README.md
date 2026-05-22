# screens/devices/widgets/

Widgets locales de la pantalla de dispositivos.

## `device_card.dart`

Card glassmórfica que representa un dispositivo en la lista.

**Muestra:**
- Nombre del dispositivo
- Tipo con ícono: ⚡ energía / 💧 agua
- Ubicación
- Chip de estado: `EN LÍNEA` (verde) / `FUERA DE LÍNEA` (rojo)
- Última lectura relevante (potencia en W o flujo en L/min)
- Timestamp de la última medición

**Estado online/offline:** se calcula comparando `device.lastSeenAt` con `DateTime.now()`. Si la diferencia supera 5 minutos, el dispositivo se marca como offline — independientemente de lo que diga el backend.

> **Dato curioso:** el umbral de 5 minutos es conservador a propósito. Los ESP32 envían datos cada 30 segundos, así que si no hay lectura en 5 minutos ya hay un problema real de conectividad.
