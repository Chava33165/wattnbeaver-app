# screens/water/

Pantalla de historial hídrico. Estructura idéntica a `energy_screen.dart` pero para agua.

## Estructura

```
WaterScreen
  ├── Resumen superior  (totalLiters, avgFlow, changePercent)
  ├── Selector de período  (Día / Semana / Mes / Año)
  ├── [solo vista Semana] Selector de día  (Lun–Dom chips)
  ├── Gráfica de barras  (fl_chart, datos de WaterProvider)
  └── Lista de sensores de agua
```

## Unidades

| Magnitud | Unidad |
|----------|--------|
| Flujo instantáneo | L/min |
| Volumen acumulado | L |
| Comparación | % vs período anterior |

## Selector de día semanal

Funciona igual que en `EnergyScreen`:
1. Aparece solo en modo **Semana**
2. Chip seleccionado filtra `rawWeekHourlyData` de `WaterProvider`
3. La gráfica muestra el consumo hora a hora del día elegido

## Diferencias con EnergyScreen

- Color de acento: `cieloMedio` (azul) en lugar de `mentaMedio` (verde)
- Unidades: litros / L/min en lugar de kWh / W
- Provider: `WaterProvider` en lugar de `EnergyProvider`
- Lista inferior: sensores de agua en lugar de dispositivos de energía

> **Dato curioso:** aunque la UI de agua y energía es casi idéntica, los modelos `WaterWeek` y `EnergyWeek` son independientes porque el backend devuelve estructuras de respuesta ligeramente distintas para cada uno.
