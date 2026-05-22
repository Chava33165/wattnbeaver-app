# screens/devices/

Gestión completa de dispositivos ESP32 (y Tasmota). Cuatro pantallas que cubren el ciclo de vida de un dispositivo: listar → añadir → provisionar → ver detalle.

## Pantallas

### `devices_screen.dart`
Lista de todos los dispositivos vinculados.
- Buscador con filtro por nombre
- Filtro por tipo: **Todos / Energía / Agua**
- Chip de estado en línea/fuera de línea (ventana de 5 min sin lectura = offline)
- FAB (botón flotante) → `AddDeviceScreen`
- Tap en una card → `DeviceDetailScreen` (pasa el `Device` como argumento)

### `add_device_screen.dart`
Formulario para vincular un nuevo dispositivo.
- Selección de tipo (Energía / Agua)
- Nombre y ubicación
- Llama a `POST /devices/link` y navega a la provisión

### `provision_device_screen.dart`
Flujo de provisión Wi-Fi para ESP32 en modo AP. Usa `ProvisionService`:
1. Conecta al AP del ESP32 (`192.168.4.1`)
2. Obtiene `device_id`, `type` y `firmware` del dispositivo
3. Envía SSID + contraseña + `server_url` + `api_key`
4. El ESP32 se reinicia y se conecta a la red

Soporta dos firmwares:
- **Custom ESP32** — API REST propia en `192.168.4.1`
- **Tasmota (Sonoff S31)** — configura via comandos HTTP de Tasmota

### `device_detail_screen.dart`
Detalle de un dispositivo. Lee el `Device` pasado como argumento via `ModalRoute.of(context)?.settings.arguments`. Muestra lecturas actuales, historial reciente y permite rotar la API key.

> **Dato curioso:** `ProvisionService.configureTasmota()` genera un script **Berry Rule** completo que el Sonoff ejecuta cada 30 segundos para enviar las lecturas de energía al backend — todo sin modificar el firmware del dispositivo.
