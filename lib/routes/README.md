# routes/

Sistema de navegación centralizado. Dos archivos, responsabilidad clara.

## Archivos

### `app_routes.dart`
Constantes de rutas como strings. Nunca se escribe `'/devices/detail'` directamente en el código — siempre `AppRoutes.deviceDetail`:

```dart
AppRoutes.splash          // '/'
AppRoutes.login           // '/login'
AppRoutes.register        // '/register'
AppRoutes.dashboard       // '/dashboard'
AppRoutes.devices         // '/devices'
AppRoutes.addDevice       // '/devices/add'
AppRoutes.provisionDevice // '/devices/provision'
AppRoutes.deviceDetail    // '/devices/detail'
AppRoutes.energyDetail    // '/energy'
AppRoutes.waterDetail     // '/water'
AppRoutes.alerts          // '/alerts'
AppRoutes.gamification    // '/gamification'
AppRoutes.profile         // '/profile'
AppRoutes.settings        // '/settings'
AppRoutes.reports         // '/reports'
AppRoutes.onboarding      // '/onboarding'
```

### `route_generator.dart`
`RouteGenerator.generateRoute(RouteSettings)` — un `switch` que mapea cada string a su `MaterialPageRoute`. Si la ruta no existe, devuelve una pantalla de error en lugar de crashear.

`DeviceDetailScreen` es el único caso especial: pasa el `settings` original para que la pantalla lea el device desde `ModalRoute.of(context)?.settings.arguments`.

> **Dato curioso:** el flujo splash → onboarding → dashboard usa `pushReplacementNamed` en cada paso, así el usuario no puede regresar con el botón back a la splash o al onboarding una vez que está autenticado.
