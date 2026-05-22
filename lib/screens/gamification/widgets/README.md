# screens/gamification/widgets/

Tres widgets que componen los tabs de la pantalla de gamificación.

## `achievement_card.dart`

Card de insignia con tres estados visuales:

| Estado | Apariencia |
|--------|-----------|
| `locked` | Ícono gris, sin progreso, overlay opaco |
| `in_progress` | Ícono con color de categoría + barra de progreso |
| `completed` | Ícono brillante + checkmark + fecha de obtención |

El color del ícono varía por categoría:
- Energía → menta
- Agua → azul cielo
- Racha → naranja
- Social → lavanda

## `challenge_card.dart`

Card de reto activo.
- Nombre del reto en `title3`
- Descripción en `bodyMedium`
- `LinearProgressIndicator` con `progressPercent` del modelo
- Texto `"X / Y"` debajo de la barra
- Badge de recompensa: `"🎯 +X pts"`
- Badge de tiempo: `"⏱ X días"` (rojo si < 3 días)

## `leaderboard_item.dart`

Fila de ranking.
- Posición con medalla para top 3 (🥇🥈🥉), número simple para el resto
- Avatar con inicial del nombre
- Nombre + nivel
- Puntos en grande a la derecha
- `FlameWidget` compacto con la racha del usuario

> **Dato curioso:** el `leaderboard_item` resalta la fila del usuario actual comparando el `id` del entry con el `id` almacenado en `AuthProvider` — sin necesidad de un campo `isMe` en el modelo.
