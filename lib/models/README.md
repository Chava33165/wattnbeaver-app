# models/

Clases de datos puras. Cada modelo sabe parsear JSON del backend y nada más — sin lógica de negocio compleja, sin dependencias de Flutter.

## Modelos

| Archivo | Clase(s) | Describe |
|---------|---------|----------|
| `user.dart` | `User` | id, name, email, role, avatar, createdAt |
| `auth_response.dart` | `AuthResponse` | Respuesta de login/register: token + User |
| `api_response.dart` | `ApiResponse<T>` | Wrapper genérico: success, message, data |
| `device.dart` | `Device`, `DeviceReading` | ESP32: tipo, estado, última lectura |
| `energy_summary.dart` | `EnergySummary` | totalKwh, avgPower, peakPower, changePercent |
| `energy_week.dart` | `EnergyWeek`, `EnergyDay` | Histórico agrupado por período |
| `energy_reading.dart` | `EnergyReading` | Lectura puntual: power, voltage, current, energy |
| `water_summary.dart` | `WaterSummary` | totalLiters, avgFlow, peakFlow, changePercent |
| `water_week.dart` | `WaterWeek`, `WaterDay` | Histórico agrupado por período |
| `gamification.dart` | `Gamification` | totalPoints, currentLevel, currentStreak, bestStreak, rank |
| `achievement.dart` | `Achievement` | insignia con status: locked / in_progress / completed |
| `challenge.dart` | `Challenge` | reto activo con progressPercent y daysRemaining |
| `leaderboard.dart` | `LeaderboardEntry`, `LeaderboardData` | Ranking global + posición propia |
| `alert.dart` | `Alert` | Alerta con severity: critical / warning / info |

## Patrón de parseo

El backend puede devolver números como strings o como enteros. Todos los modelos usan este patrón para ser robustos:

```dart
double.tryParse(json['field']?.toString() ?? '0') ?? 0.0
```

## `EnergyWeek` — cuatro constructores

`EnergyWeek` tiene cuatro factories distintos porque el backend devuelve estructuras diferentes según el período:

```dart
EnergyWeek.fromJson(data)            // genérico
EnergyWeek.fromHourly(data)          // vista de día → puntos por hora
EnergyWeek.fromGroupedByDay(data)    // vista semanal → un punto por día
EnergyWeek.fromGroupedByMonth(data)  // vista mensual / anual
```

> **Dato curioso:** `Gamification` implementa `progressToNextLevel` con los 10 umbrales reales del backend (0, 100, 300, 600, 1000…) en lugar de una división uniforme, para que la barra de progreso refleje exactamente lo que el servidor calcula.
