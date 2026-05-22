# widgets/charts/

Visualizaciones de datos animadas. Todos usan `CustomPainter` o `AnimationController` — sin librerías de gráficas externas (esas están en `fl_chart` para las gráficas de barras).

## `flame_widget.dart`

Flamita animada para la **racha de energía**.

- **Forma:** path de llama dibujado con `CustomPainter`
- **Tamaño:** 42 px (racha 0) → 92 px (racha máxima)
- **Color:**
  - 🟡 Amarillo `#FFD600` (1–3 días)
  - 🟠 Naranja `#FF5E00` (4–6 días)
  - 🟣 Púrpura `#9B44D6` (7+ días)
- **Animación:** wobble lateral ±1° + respiración (escala 0.94→1.06, 950 ms)
- **Sin racha:** ícono gris `local_fire_department_outlined` + texto "¡Empieza hoy!"

```dart
FlameWidget(streak: 5, maxStreak: 7)
```

## `water_drop_widget.dart`

Gotita animada para la **racha de agua**.

- **Forma:** drop path con gradiente y brillo interior
- **Tamaño:** 42 px → 92 px según nivel de racha
- **Color:** azul claro `#72D0F0` → azul marino `#1A5A80` (interpolación de 3 puntos)
- **Animación:** respiración (escala 0.93→1.07, 1300 ms) + glow difuminado
- **Efecto extra:** `MaskFilter.blur` en la capa de fondo para el glow

```dart
WaterDropWidget(streak: 3, maxStreak: 7)
```

## `activity_ring.dart`

Anillo circular de progreso.

- Arco de fondo (color faded) + arco de progreso (coloreado)
- Progreso: `0.0` → `1.0`
- Permite widget hijo en el centro (ej. texto con el porcentaje)
- Se anima con `Tween<double>` al montar

```dart
ActivityRing(
  progress: 0.65,
  color: AppColors.lavandaMedio,
  child: Text('65%'),
)
```

> **Dato curioso:** `FlameWidget` y `WaterDropWidget` comparten la misma función helper `calcFlameStreak()` — calcula los días consecutivos con consumo por encima del promedio a partir de un `Map<int, double>` (día de la semana → valor). Es el fallback cuando el dato de `gamification.currentStreak` aún no está disponible.
