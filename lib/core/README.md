# core/

Base de toda la app. Nada en `core/` depende de pantallas ni de providers — es el código que cualquier parte de la app puede importar sin crear dependencias circulares.

## Subcarpetas

| Carpeta | Qué contiene |
|---------|-------------|
| `constants/` | Colores, URLs, topics MQTT y strings de UI |
| `theme/` | Material 3 + sistema neumórfico + glassmorphism |
| `utils/` | Formateadores de fecha, números y validadores de formulario |
| `widgets/` | Widgets primitivos: `GlassCard`, `NeuButton`, `NeuGlassScaffold` |

## Regla de dependencias

```
screens/  →  core/
providers/  →  core/
models/  →  (no depende de core)
core/  →  (no depende de nada propio)
```

> **Dato curioso:** `NeuGlass` implementa **dos** estilos simultáneamente: neumorfismo (sombras simétricas para efecto de relieve) y glassmorphism (blur + transparencia). Cada componente elige cuál usar según el contexto visual.
