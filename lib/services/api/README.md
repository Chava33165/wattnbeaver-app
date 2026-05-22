# services/api/

Cliente HTTP para el backend REST de WattBeaver. Un archivo base + 7 archivos de dominio.

## `api_service.dart` — base

Wrapper sobre el paquete `http` con:
- **Base URL** desde `ApiConstants.baseUrl`
- **JWT automático** — lee el token de `StorageService` y lo pone en `Authorization: Bearer`
- **Métodos**: `get()`, `post()`, `put()`, `delete()`
- **Manejo de errores**: respuestas 4xx/5xx lanzan `ApiException` con el mensaje del servidor

```dart
final response = await _apiService.get(ApiConstants.energyTotal);
```

## Archivos de dominio

| Archivo | Métodos principales |
|---------|-------------------|
| `auth_api.dart` | `login()`, `register()`, `getProfile()` |
| `energy_api.dart` | `getTotal()`, `getHistory(period)`, `getWeeklyStats(start, end)`, `getDevices()` |
| `water_api.dart` | `getTotal()`, `getHistory(period)`, `getWeeklyStats(start, end)`, `getSensors()` |
| `device_api.dart` | `getDevices()`, `linkDevice()`, `getDevice(id)`, `rotateKey(id)`, `deleteDevice(id)` |
| `alerts_api.dart` | `getAlerts(acknowledged, limit)`, `acknowledge(id)`, `resolve(id)` |
| `gamification_api.dart` | `getProfile()`, `getAchievements()`, `getChallenges()`, `getLeaderboard()` |
| `reports_api.dart` | `getDaily()`, `getWeekly()`, `getMonthly()`, `exportReport(period, format)` |

## Patrón de llamada

Todos los métodos siguen el mismo patrón:

```dart
Future<EnergySummary> getTotal() async {
  final response = await _apiService.get(ApiConstants.energyTotal);
  return EnergySummary.fromJson(response['data']);
}
```

> **Dato curioso:** `energy_api.dart` llama a `getWeeklyStats` con `startDate` y `endDate` calculados en el cliente (lunes y domingo de la semana actual) porque el backend no tiene un endpoint que infiera la semana automáticamente.
