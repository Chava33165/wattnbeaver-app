# screens/

Todas las pantallas de WattBeaver. Cada carpeta agrupa la pantalla principal con sus widgets locales cuando los tiene.

## Mapa de pantallas

```
splash/          Entrada: verifica JWT → onboarding o dashboard
auth/            login_screen · register_screen
onboarding/      5 slides animados (solo se muestra la primera vez)
dashboard/       Hub principal con 5 tabs via IndexedStack + MQTT live
  └── widgets/   energy_card · water_card · gamification_widget
                 habit_calendar · weekly_chart · device_quick_access
energy/          Historial eléctrico con selector de período y día
water/           Historial hídrico (estructura paralela a energy/)
devices/         Lista, detalle, añadir y provisión de ESP32
  └── widgets/   device_card
gamification/    Logros · Retos · Leaderboard (3 tabs)
  └── widgets/   achievement_card · challenge_card · leaderboard_item
alerts/          Lista de alertas con filtros y reconocimiento
reports/         Resúmenes de consumo y costo diario/semanal/mensual
profile/         Perfil de usuario + settings_screen
```

## Convenciones

- Todos los archivos termina en `_screen.dart`
- Después de cualquier `await`, siempre se verifica `if (!mounted) return` antes de usar `context` o `Navigator`
- Los widgets locales de cada pantalla viven en su subcarpeta `widgets/` — si un widget se usa en más de una pantalla, sube a `lib/widgets/`
