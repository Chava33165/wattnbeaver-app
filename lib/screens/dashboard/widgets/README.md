# screens/dashboard/widgets/

Los 6 widgets que componen la vista home del dashboard. Son locales a esta pantalla — si alguno fuera necesario en otro lugar, subiría a `lib/widgets/`.

## Widgets

### `energy_card.dart`
Card glassmórfica con consumo eléctrico del día.
- Muestra **kWh** normalmente, **W** cuando el consumo < 1 Wh pero hay potencia activa
- Badge de cambio porcentual vs día anterior (verde ↓ / rojo ↑)
- Costo estimado en MXN (`kWh × $2.50`)
- `FlameWidget` con racha del backend (`gamification.currentStreak`)
- Ícono ℹ️ que abre diálogo explicando los colores de la racha

### `water_card.dart`
Paralela a `EnergyCard` pero para agua.
- `WaterDropWidget` animado con racha del backend
- Badge de comparación vs promedio semanal
- Mismo ícono ℹ️ con descripción de los niveles de racha de agua

### `gamification_widget.dart`
Resumen compacto de gamificación que lleva al detalle.
- Nivel actual + barra de progreso con `ActivityRing`
- Puntos totales
- `FlameWidget` animado con la racha actual
- Flecha de navegación → `GamificationScreen`

### `habit_calendar.dart`
Calendario horizontal de la semana actual. Cada día muestra si hubo medición de energía y/o agua. Sirve de indicador visual de la consistencia del usuario.

### `weekly_chart.dart`
Mini gráfica de barras (via `fl_chart`) con el consumo de los últimos 7 días. Las barras del día actual se colorean diferente para destacar el valor más reciente.

### `device_quick_access.dart`
Scroll horizontal de chips para los dispositivos online. Toca uno para ir directo a su detalle.

> **Dato curioso:** `EnergyCard` y `WaterCard` reciben `Gamification?` como parámetro para usar la racha real del backend. Si `gamification` es null (aún cargando), hacen fallback calculando la racha localmente con `calcFlameStreak()` sobre los datos históricos de la semana.
