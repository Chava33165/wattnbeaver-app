# services/storage/

Capa de persistencia local. Wrapper sobre `shared_preferences` para no esparcir strings de clave por todo el código.

## `storage_service.dart`

Todos los métodos son `static` — no hace falta instanciar la clase.

### JWT Token

```dart
StorageService.saveToken(String token)
StorageService.getToken()        // → String?
StorageService.deleteToken()
StorageService.isTokenValid()    // → bool  (decodifica y verifica expiración)
```

### Datos de usuario

```dart
StorageService.saveUser(User user)
StorageService.getUser()         // → User?  (desde JSON guardado)
StorageService.deleteUser()
```

### Flags de app

```dart
StorageService.hasCompletedOnboarding()    // → Future<bool>
StorageService.setOnboardingCompleted()
StorageService.clearAll()                  // logout completo
```

## Claves internas

| Clave | Valor |
|-------|-------|
| `auth_token` | JWT string |
| `user_data` | JSON del User |
| `onboarding_done` | bool |

> **Dato curioso:** `isTokenValid()` usa `jwt_decoder` para leer el claim `exp` del token localmente, sin hacer ninguna petición al backend. Si el token expiró, `AuthProvider.checkAuth()` sabe que debe pedir login sin gastar una petición de red.
