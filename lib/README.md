# lib/

Raíz del código Dart de WattBeaver. Aquí vive `main.dart`, que arranca la app.

## ¿Qué hace main.dart?

1. Registra los **8 providers** globales en `MultiProvider`
2. Configura el `RouteGenerator` como sistema de navegación
3. Apunta a `SplashScreen` como pantalla inicial
4. Aplica el tema global (`AppTheme.light`)

```
main.dart
  └── MultiProvider
        ├── AuthProvider
        ├── DashboardProvider
        ├── EnergyProvider
        ├── WaterProvider
        ├── DevicesProvider
        ├── GamificationProvider
        ├── AlertsProvider
        └── ReportsProvider
```

## Carpetas

| Carpeta | Rol |
|---------|-----|
| `core/` | Constantes, tema, utilidades y widgets base |
| `models/` | Estructuras de datos (JSON ↔ Dart) |
| `providers/` | Estado global con `ChangeNotifier` |
| `routes/` | Tabla de rutas y generador de pantallas |
| `screens/` | Todas las pantallas de la app |
| `services/` | Comunicación con API REST, MQTT y almacenamiento local |
| `widgets/` | Widgets reutilizables compartidos entre pantallas |

> **Dato curioso:** el provider que recibe actualizaciones MQTT en tiempo real es `DashboardProvider`; el resto solo consulta la API REST. Así la pantalla principal siempre muestra datos frescos sin necesidad de hacer pull-to-refresh.
