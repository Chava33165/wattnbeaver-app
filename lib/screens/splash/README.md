# screens/splash/

Primera pantalla que ve el usuario. Dura ~2 segundos y decide a dónde ir.

## Lógica de decisión

```
initState()
  ├── Inicia animación de fade-in (800 ms)
  └── _checkAuth()
        ├── await Future.delayed(2s)  ← mínimo para ver el logo
        ├── authProvider.checkAuth()  ← valida JWT en SharedPreferences
        │
        ├── [autenticado]
        │     └── StorageService.hasCompletedOnboarding()
        │           ├── [sí] → pushReplacement('/dashboard')
        │           └── [no] → pushReplacement('/onboarding')
        │
        └── [no autenticado] → pushReplacement('/login')
```

## UI

- Logo `watt.jpeg` con bordes redondeados
- Nombre de la app en color `energyPrimary`
- Tagline `"Monitorea, Ahorra, Gana"` en gris
- `CircularProgressIndicator` con stroke de 2 px al fondo

> **Dato curioso:** la animación de fade-in y la verificación de auth corren en paralelo desde `initState` — el logo aparece suavemente mientras el JWT se valida en segundo plano, sin bloquear la UI.
