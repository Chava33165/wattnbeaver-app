# screens/profile/

Información del usuario y configuración de la app. Dos pantallas simples de consulta y ajuste.

## `profile_screen.dart`

Vista del perfil del usuario autenticado.

**Secciones:**
- Avatar con inicial del nombre (círculo de menta)
- Nombre, email y rol
- Resumen de gamificación: puntos, nivel actual, posición en el ranking
- Menú de acciones:
  - **Editar perfil** → formulario de nombre (pendiente)
  - **Notificaciones** → `SettingsScreen`
  - **Ayuda** → abre URL de soporte
- Botón **Cerrar sesión** (rojo) — llama a `authProvider.logout()` y va a login

## `settings_screen.dart`

Preferencias de la app.
- Toggle de notificaciones push (energía / agua / alertas)
- Toggle de tema oscuro/claro
- Selector de umbral de alerta de consumo

Los toggles usan `NeuToggle` de `core/widgets/` y persisten en `StorageService`.

> **Dato curioso:** el logout llama a `authProvider.logout()` que borra el token de `SharedPreferences` y resetea el estado de todos los providers vía `notifyListeners()` — no es necesario navegar con `pushAndRemoveUntil` porque el `SplashScreen` ya redirige a login cuando no hay token válido.
