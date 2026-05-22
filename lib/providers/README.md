# providers/

Estado global de la app usando el patrón `ChangeNotifier` + `Provider`. Cada provider es responsable de un dominio de datos y expone métodos para cargarlo, mutarlo y notificar a los widgets.

## Los 8 providers

| Provider | Estado que gestiona |
|----------|---------------------|
| `AuthProvider` | Sesión: token JWT, objeto `User`, isAuthenticated. Persiste en `StorageService` |
| `DashboardProvider` | Resumen del home: energySummary, waterSummary, gamification, alertas recientes. Recibe actualizaciones MQTT via `updateEnergyFromMqtt` / `updateWaterFromMqtt` |
| `EnergyProvider` | Histórico de energía, período seleccionado, `selectedWeekDay`, `rawWeekHourlyData` |
| `WaterProvider` | Ídem para agua |
| `DevicesProvider` | Lista de dispositivos, filtros, dispositivo seleccionado, operaciones CRUD |
| `GamificationProvider` | Perfil, logros, retos activos y leaderboard — carga todo con `loadAll()` |
| `AlertsProvider` | Lista de alertas, filtros por severidad, reconocimiento |
| `ReportsProvider` | Reportes diario/semanal/mensual con costos de energía y agua |

## Ciclo de vida típico

```
Widget.initState()
  └── context.read<XProvider>().load()
        ├── isLoading = true; notifyListeners()
        ├── await api.fetch()
        ├── data = parseResponse()
        └── isLoading = false; notifyListeners()

Widget.build()
  └── context.watch<XProvider>()  →  reconstruye cuando hay datos
```

## MQTT → Dashboard

`DashboardProvider` es el único provider con actualización reactiva:

```dart
// Llamado por MqttHandler cuando llega un mensaje
provider.updateEnergyFromMqtt(power, voltage, current)
provider.updateWaterFromMqtt(flow, total)
```

Esto actualiza las cards del home sin necesidad de hacer una llamada REST adicional.

> **Dato curioso:** `EnergyProvider` y `WaterProvider` limpian `selectedWeekDay` automáticamente cuando el usuario cambia de período (ej. de semana a mes), evitando que quede seleccionado un día de la semana que ya no está visible.
