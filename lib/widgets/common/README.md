# widgets/common/

Los bloques fundamentales de formularios y estados de UI. Se usan en auth, settings, provisionamiento y cualquier flujo con interacción del usuario.

## `custom_button.dart`

Botón de acción principal de la app.

```dart
CustomButton(
  text: 'Iniciar sesión',   // requerido (NO usar 'label')
  onPressed: _handleLogin,
  isLoading: authProvider.isLoading,
  color: AppColors.mentaMedio,
  outlined: false,
)
```

Cuando `isLoading: true`, reemplaza el texto por un `CircularProgressIndicator` y deshabilita el tap.

## `custom_text_field.dart`

TextField estilizado con el tema de la app.

```dart
CustomTextField(
  label: 'Correo electrónico',   // requerido (NO usar 'hint')
  controller: _emailController,
  validator: Validators.validateEmail,
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
)
```

Soporta `obscureText` para contraseñas, `suffixIcon` para el toggle de visibilidad, y `onChanged` para validación en tiempo real.

## `empty_state.dart`

Placeholder cuando una lista no tiene datos.
- Ícono grande (configurable)
- Título y subtítulo
- Botón de acción opcional ("Agregar dispositivo", "Reintentar")

## `error_display.dart`

Vista de error con mensaje y botón de reintento.
- Ícono de error
- Mensaje del error (del provider)
- Callback `onRetry` para relanzar la carga

## `loading_indicator.dart`

Spinner de carga centrado con el color de menta. Se usa como placeholder mientras los providers cargan datos.

> **Dato curioso:** `CustomTextField` usa `label` y no `hint` como prop requerido — esto es para seguir el estilo de `InputDecoration` de Material con el label flotante, que da más espacio visual y evita que el texto de ayuda desaparezca cuando el usuario empieza a escribir.
