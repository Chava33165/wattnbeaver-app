# widgets/

Widgets reutilizables compartidos entre múltiples pantallas. Si un widget lo usa solo una pantalla, vive en `screens/<pantalla>/widgets/`. Si lo usan dos o más, vive aquí.

## Subcarpetas

| Carpeta | Qué contiene |
|---------|-------------|
| `cards/` | `StatCard` — contenedor genérico para métricas |
| `charts/` | `FlameWidget` · `WaterDropWidget` · `ActivityRing` |
| `common/` | `CustomButton` · `CustomTextField` · `EmptyState` · `ErrorDisplay` · `LoadingIndicator` |

## Regla de uso

```
screens/dashboard/widgets/energy_card.dart
  └── usa: FlameWidget  (de lib/widgets/charts/)
  └── usa: GlassCard    (de lib/core/widgets/)

screens/gamification/widgets/leaderboard_item.dart
  └── usa: FlameWidget  (de lib/widgets/charts/)
```

`FlameWidget` y `WaterDropWidget` son los más reutilizados — aparecen en las cards del dashboard, en la pantalla de gamificación y en el leaderboard.

> **Dato curioso:** `ActivityRing` (el anillo de progreso circular) se usa exclusivamente en la pantalla de gamificación, pero vive aquí en `charts/` porque es un widget visual de datos, no un componente de formulario.
