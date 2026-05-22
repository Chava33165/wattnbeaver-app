# screens/dashboard/

El corazón de la app. `DashboardScreen` es un `Scaffold` con barra de navegación inferior glassmórfica que contiene 5 tabs vía `IndexedStack`.

## Tabs

| Índice | Tab | Pantalla |
|--------|-----|---------|
| 0 | 🏠 Home | `_DashboardHome` — resumen live + cards |
| 1 | ⚡ Energía | `EnergyScreen` |
| 2 | 💧 Agua | `WaterScreen` |
| 3 | 📡 Dispositivos | `DevicesScreen` |
| 4 | 👤 Perfil | `ProfileScreen` |

## `_DashboardHome`

La vista del tab 0. Carga datos al iniciar y muestra:

1. **Saludo** con nombre del usuario
2. **EnergyCard** — kWh / W actuales + racha de energía (FlameWidget)
3. **WaterCard** — litros actuales + racha de agua (WaterDropWidget)
4. **DeviceQuickAccess** — acceso rápido a los dispositivos online
5. **GamificationWidget** — puntos, nivel, streak y flecha a gamification
6. **HabitCalendar** — calendario de hábitos de la semana actual

## MQTT en tiempo real

Al montar `_DashboardHome`, se inicializa el servicio MQTT. Los mensajes entrantes llegan a `DashboardProvider.updateEnergyFromMqtt()` y `updateWaterFromMqtt()`, que llaman `notifyListeners()` para actualizar las cards sin ninguna petición HTTP adicional.

## Barra de navegación

Usa `GlassCard` con `BackdropFilter` para el efecto de cristal. El ícono activo se anima con `AnimatedContainer` que cambia de tamaño y añade un fondo de menta.

> **Dato curioso:** se usa `IndexedStack` en lugar de `Navigator` para los tabs. Esto mantiene el estado de cada pantalla vivo aunque el usuario cambie de tab — la gráfica de energía no se recarga cada vez que vuelves a ella.
