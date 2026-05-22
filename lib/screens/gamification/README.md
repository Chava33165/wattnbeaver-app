# screens/gamification/

El módulo que hace del ahorro un juego. Tres tabs con información de progreso, retos activos y competencia social.

## Estructura

```
GamificationScreen
  ├── Banner de perfil
  │     ├── Avatar con nivel
  │     ├── Puntos totales
  │     ├── Barra de progreso al siguiente nivel
  │     └── Racha actual (días consecutivos)
  │
  └── TabBar  (3 tabs)
        ├── 🏆 Logros
        ├── 🎯 Retos
        └── 🏅 Leaderboard
```

## Tab Logros

Grid de `AchievementCard`. Cada insignia puede estar en uno de tres estados:
- **Bloqueado** — gris, sin progreso
- **En progreso** — con barra de porcentaje
- **Completado** — color completo + fecha de obtención

## Tab Retos

Lista de `ChallengeCard`. Cada reto muestra:
- Nombre y descripción
- Barra de progreso (`currentValue / targetValue`)
- Puntos de recompensa
- Días restantes (`daysRemaining`)

## Tab Leaderboard

Lista de `LeaderboardItem` con el ranking global. La fila del usuario actual se resalta con un fondo de menta. Las primeras 3 posiciones tienen ícono de medalla.

## Sistema de niveles

10 niveles con umbrales no lineales (el modelo `Gamification` los maneja):

```
Lv1 → Lv2: 100 pts   Lv5 → Lv6: 500 pts
Lv2 → Lv3: 200 pts   Lv6 → Lv7: 600 pts
Lv3 → Lv4: 300 pts   ...
```

> **Dato curioso:** la barra de progreso del banner usa `ActivityRing` (el widget de anillo circular de `lib/widgets/charts/`) con `progressToNextLevel` calculado directamente en el modelo, no en el provider ni en la pantalla.
