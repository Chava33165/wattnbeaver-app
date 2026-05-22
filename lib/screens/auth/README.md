# screens/auth/

Dos pantallas de acceso. Comparten los mismos widgets (`CustomTextField`, `CustomButton`) y la misma lógica de manejo de errores.

## login_screen.dart

- Formulario: email + contraseña (con toggle de visibilidad)
- Al enviar: `authProvider.login()` → si falla, muestra `SnackBar` con el error
- En éxito: `pushReplacementNamed('/dashboard')`
- Link a register en la parte inferior

## register_screen.dart

- Formulario: nombre + email + contraseña + confirmar contraseña
- Indicador de fortaleza de contraseña en tiempo real:
  - `Débil` (rojo) → menos de 6 caracteres
  - `Media` (naranja) → 6+ caracteres sin mezcla
  - `Fuerte` (verde) → 8+ caracteres con letras y números
- Validación de que las dos contraseñas coincidan antes de enviar
- Al registrar exitosamente: `pushReplacementNamed('/dashboard')`

## Validación

Toda la validación usa las funciones de `core/utils/validators.dart` en el parámetro `validator` del `Form`. Se activa solo al presionar el botón (no en tiempo real, excepto el indicador de fortaleza).

> **Dato curioso:** ambas pantallas usan `pushReplacementNamed` (no `pushNamed`) al navegar al dashboard, así el usuario no puede regresar a login con el botón de atrás una vez autenticado.
