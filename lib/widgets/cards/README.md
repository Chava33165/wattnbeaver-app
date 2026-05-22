# widgets/cards/

Contenedores de card reutilizables.

## `stat_card.dart`

El contenedor más simple de la app: acepta cualquier `child` y le añade el fondo glassmórfico con padding configurable.

```dart
StatCard(
  child: Column(
    children: [
      Text('3.4 kWh'),
      Text('Consumo hoy'),
    ],
  ),
  padding: const EdgeInsets.all(16),
)
```

**Cuándo usar `StatCard` vs `GlassCard`:**
- `GlassCard` (en `core/widgets/`) es el primitivo base — blur, borde, fill
- `StatCard` es un wrapper de `GlassCard` con semántica de "tarjeta de métrica", pensado para usarse en listas o grids de estadísticas

> **Dato curioso:** `StatCard` es intencionalmente minimalista. La lógica de qué mostrar adentro (ícono, número, label, badge) siempre vive en el widget hijo — `StatCard` solo se encarga del contenedor.
