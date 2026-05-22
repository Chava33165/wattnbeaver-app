# screens/reports/

Resúmenes de consumo con costo estimado. Útil para tener una vista ejecutiva de lo que gasta el hogar en un período.

## Períodos

| Período | Endpoint | Contenido |
|---------|---------|-----------|
| Diario | `GET /reports/daily` | Consumo de ayer vs promedio |
| Semanal | `GET /reports/weekly` | Resumen de los últimos 7 días |
| Mensual | `GET /reports/monthly` | Mes actual vs mes anterior |

## Métricas mostradas

- Consumo total de energía (kWh)
- Consumo total de agua (L)
- Costo estimado de energía (MXN)
- Costo estimado de agua (MXN)
- Ahorro vs período anterior (si aplica)
- Dispositivo que más consumió

## Exportación

El backend soporta `GET /reports/export/{period}/{format}` con formato `pdf` o `csv`. El botón de exportar usa `url_launcher` para abrir la URL de descarga en el navegador.

## ReportsProvider

```dart
reportsProvider.loadReport(period: 'daily' | 'weekly' | 'monthly')
```

Extrae los valores del JSON del backend con `double.tryParse()` — el mismo patrón robusto que todos los modelos.

> **Dato curioso:** los costos de energía se calculan en el backend usando la tarifa doméstica promedio de CFE — la app solo los muestra, no hace la conversión local.
