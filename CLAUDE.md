# WattBeaver — Flutter App

App móvil IoT para monitoreo de energía y agua con gamificación.

## Estructura del proyecto

```
lib/
  core/constants/      ← app_colors.dart, api_constants.dart, mqtt_topics.dart, app_strings.dart
  core/theme/          ← app_theme.dart, text_styles.dart, dimensions.dart
  core/utils/          ← validators.dart, date_formatter.dart, number_formatter.dart
  models/              ← todos los modelos de datos (fromJson/toJson)
  services/api/        ← api_service.dart (base HTTP), auth/energy/water/device/alerts/gamification_api.dart
  services/mqtt/       ← mqtt_service.dart, mqtt_handler.dart
  services/storage/    ← storage_service.dart (SharedPreferences)
  providers/           ← auth, dashboard, devices, energy, water, alerts, gamification
  screens/             ← splash, auth, dashboard, devices, energy, water, alerts, gamification, profile
  widgets/             ← common/ (button, textfield, loading), cards/, charts/
  routes/              ← app_routes.dart, route_generator.dart
```

## Backend

- REST API: `http://100.69.129.83:3000/api/v1`
- MQTT broker: `100.69.129.83:1883`
- Backend fuente: `c:\WATT\wattnbeaver-backend`

**IMPORTANTE:** El folder `App_Documentacion` del backend describe endpoints PLANEADOS que no existen.
Siempre leer los controllers reales en `backend/src/controllers/` para conocer los endpoints y formatos de respuesta reales.

## Endpoints reales implementados

```
POST /auth/login          → {data: {token, user: {id, name, email}}}
POST /auth/register       → {data: {token, user}}
GET  /auth/profile        → {data: {user: {id, name, email, role}}}

GET  /devices             → {data: {devices: [], stats: {}, total: N}}
POST /devices/link        → {data: {device: {...}}}
DELETE /devices/:id

GET  /energy/total        → {data: {totalPower: "X.XX", totalEnergy: "X.XXX", deviceCount, onlineDevices}}
GET  /energy/history?period=week  → {data: {data: [{hour: "ISO", avg_power, total_energy}]}}

GET  /water/total         → {data: {totalFlow: "X.XX", totalVolume: "X.XX", sensorCount, onlineSensors}}
GET  /water/history?period=week   → {data: {data: [{hour: "ISO", avg_flow, total_volume}]}}

GET  /alerts?acknowledged=false&limit=50  → {data: {alerts: [], total: N}}
POST /alerts/:id/acknowledge

GET  /gamification/profile      → {data: {profile: {user_id, total_points, current_level, current_streak, best_streak, rank}}}
GET  /gamification/achievements → {data: {achievements: [{..., completed: 0|1}]}}
GET  /gamification/challenges   → {data: {challenges: []}}
GET  /gamification/leaderboard  → {data: {leaderboard: [{id, name, total_points, current_level, current_streak, rank}], my_rank: N}}
```

## MQTT

- Credenciales: `backend_user` / `backend_password`
- Topic prefix: `wattnbeaber/` (typo en el backend — usar tal cual)
- Topics de energía: `wattnbeaber/energy/{device_id}/data` → `{power, voltage, current, energy, timestamp}`
- Topics de agua: `wattnbeaber/water/{sensor_id}/data` → `{flow, total, timestamp}`

## Widgets propios — API

| Widget | Params importantes |
|--------|-------------------|
| `CustomTextField` | `label` (requerido), `controller`, `validator`, `prefixIcon`, `suffixIcon`, `onChanged`, `enabled`, `obscureText`, `keyboardType` — **sin `hint`** |
| `CustomButton` | `text` (requerido, **no `label`**), `onPressed`, `isLoading`, `color`, `outlined` |
| `StatCard` | `child` (requerido), `padding` |
| `DeviceDetailScreen` | Sin constructor params — lee el device desde `ModalRoute.of(context)?.settings.arguments` |

## Convenciones

- Idioma de la UI: español
- Estado: Provider pattern (`ChangeNotifier`), 7 providers registrados en `main.dart`
- Colores por dominio: Energía `#34C759`, Agua `#007AFF`, Alerta `#FF3B30`, Gamificación `#AF52DE`
- Siempre hacer check de `context.mounted` después de cualquier `await` antes de usar `context` o `Navigator`
- Los modelos parsean con `double.tryParse(json['field']?.toString() ?? '0') ?? 0.0` porque el backend puede devolver strings o números

## Estado actual

Todos los 11 fases implementadas. `flutter analyze` → sin errores.
