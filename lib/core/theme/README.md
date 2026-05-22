# core/theme/

Sistema visual de WattBeaver. Combina **Material Design 3**, **neumorfismo** y **glassmorphism** en un solo lenguaje coherente.

## Archivos

### `app_theme.dart`
Configura el `ThemeData` de Flutter: colores seed (menta), tipografía base, formas de componentes y el scaffold background. Punto de entrada único en `main.dart`.

### `text_styles.dart`
Estilos tipográficos nombrados semánticamente (`largeTitle`, `title2`, `bodyMedium`, `chip`, `muted`…). Los estilos que dependen de contexto (modo claro/oscuro) reciben `BuildContext`.

### `dimensions.dart`
Constantes de espaciado y tamaño: paddings estándar, alturas de cards, radios de borde. Evita números mágicos dispersos por los widgets.

### `neu_glass.dart`
El corazón del sistema visual. Implementa dos paradigmas de diseño:

**Neumorfismo** (`neuRaised` / `neuInset`):
- Sombra oscura abajo-derecha + sombra clara arriba-izquierda
- Genera sensación de profundidad sin usar bordes
- `neuInset` simula el estado "presionado"

**Glassmorphism** (`glassFill` / `glassBorder`):
- Fill semitransparente (52% opaco en claro, 25% en oscuro)
- Borde blanco al 45% de opacidad
- Se combina con `BackdropFilter` en `GlassCard`

Ambos adaptan sus colores automáticamente al modo claro/oscuro.

> **Dato curioso:** `NeuButton` en `core/widgets/` usa `neuRaised` ↔ `neuInset` para animar el press físicamente: cuando el dedo toca el botón, el `BoxDecoration` cambia de raised a inset en 100 ms, creando la ilusión táctil de que la superficie se hunde.
