# services/

Todo el código de comunicación externa. La app habla con el mundo a través de tres canales:

| Subcarpeta | Canal | Protocolo |
|-----------|-------|-----------|
| `api/` | Backend REST | HTTP + JWT Bearer |
| `mqtt/` | Broker MQTT | TCP (puerto 1883) |
| `storage/` | Almacenamiento local | SharedPreferences |

Además:

| Archivo | Qué hace |
|---------|----------|
| `provision_service.dart` | Habla con ESP32 en modo AP (`192.168.4.1`) durante la provisión Wi-Fi |

## Regla de dependencias

```
providers/
  └── services/api/      (llamadas HTTP)
  └── services/mqtt/     (stream de mensajes)
  └── services/storage/  (token, onboarding flag)

screens/devices/
  └── provision_service  (solo durante la provisión)
```

Los services no conocen a los providers — la comunicación siempre fluye en un solo sentido.

> **Dato curioso:** `ProvisionService` usa un timeout de 10 segundos para todas las peticiones al ESP32 en modo AP. Si el usuario no está conectado a la red del dispositivo, la petición falla rápido en lugar de colgar la UI indefinidamente.
