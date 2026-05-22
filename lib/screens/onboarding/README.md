# screens/onboarding/

Presentación de la app para usuarios nuevos. Se muestra una sola vez: después de completarla (o saltarla), `StorageService.setOnboardingCompleted()` la marca como vista y nunca vuelve a aparecer.

## Los 5 slides

| # | Título | Icono | Colores |
|---|--------|-------|---------|
| 1 | ¡Bienvenido a WattBeaver! | `home_rounded` | Crema → Menta claro |
| 2 | Panel de control | `dashboard_rounded` | Gradiente energía (menta) |
| 3 | Energía y Agua | `bolt` + `water_drop` | Gradiente agua (azul) |
| 4 | Tus dispositivos | `devices_rounded` | Arena → Menta medio |
| 5 | Retos y logros | `emoji_events_rounded` | Gradiente gamificación (lavanda) |

## Navegación

- `PageController` con `PageView` deslizable
- Botón **Omitir** visible en los slides 1–4
- Botón **Siguiente** → avanza al siguiente slide
- Slide 5: botón **¡Empezar!** → navega al dashboard
- Indicadores de página (dots) en la parte inferior

> **Dato curioso:** el slide de Energía y Agua muestra dos íconos a la vez (`bolt` + `water_drop`) para representar visualmente los dos dominios del proyecto — es el único slide con `secondIcon`.
