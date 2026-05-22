# core/widgets/

Primitivos de UI que forman el lenguaje visual base de la app. Son los ladrillos sobre los que se construyen todos los demás widgets.

## Widgets

### `GlassCard`
El contenedor más usado de la app. Aplica glassmorphism real con `BackdropFilter`:
- Blur configurable (default 16 px)
- Borde semitransparente (blanco 45%)
- Fill adaptado al tema (claro/oscuro)
- Prop `accent` para resaltar con tinte de menta

### `NeuButton`
Botón neumórfico con retroalimentación táctil real. Usa `Listener` (no `GestureDetector`) para detectar exactamente el momento del contacto y cambiar de `neuRaised` a `neuInset` en 100 ms. Sin `InkWell`, sin ripple — efecto puramente de relieve.

### `NeuGlassScaffold`
Scaffold base que combina el fondo degradado de la app con el sistema de glassmorphism. Todas las pantallas principales lo usan como wrapper.

### `NeuSlider`
Slider personalizado con pista neumórfica y thumb de menta. Usado en configuraciones de umbral.

### `NeuToggle`
Switch neumórfico animado (alternativa al `Switch` de Material). Cambia entre `neuRaised` (apagado) y tinte de menta (encendido).

> **Dato curioso:** `GlassCard` con `accent: true` aplica un tinte de `mentaClaro` al 30% de opacidad además del blur normal — se usa en las cards de resumen del dashboard para distinguirlas visualmente del resto del contenido.
