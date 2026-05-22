# core/utils/

Funciones puras de utilidad. Sin estado, sin widgets, sin efectos secundarios.

## Archivos

### `validators.dart`
Funciones de validación para usar directamente en el parámetro `validator` de `TextFormField`:
- `validateEmail` — regex + campo requerido
- `validatePassword` — mínimo 6 caracteres
- `validateName` — mínimo 3 caracteres
- `validatePasswordConfirm` — igualdad entre dos campos

### `date_formatter.dart`
Convierte `DateTime` o strings ISO 8601 a formatos legibles en español:
- Fecha completa: `"22 mayo 2026"`
- Formato corto: `"22/05/26"`
- Solo hora: `"14:30"`
- Relativo: delega a `timeago` para `"hace 5 minutos"`

### `number_formatter.dart`
Formatea valores numéricos de energía y agua para la UI:
- `formatKwh` → `"3.45 kWh"`
- `formatWatts` → `"120 W"`
- `formatLiters` → `"14.2 L"`
- `formatFlow` → `"2.8 L/min"`
- `formatCurrency` → `"$87 MXN"`

> **Dato curioso:** la pantalla de energía usa `number_formatter` para decidir si mostrar `W` o `kWh`: si el consumo del día es menor a 1 Wh pero hay potencia activa, muestra vatios en tiempo real en lugar de cero kWh, que sería confuso para el usuario.
