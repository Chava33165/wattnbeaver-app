# screens/energy/

Pantalla completa de historial eléctrico. Permite explorar el consumo a cualquier escala de tiempo.

## Estructura

```
EnergyScreen
  ├── Resumen superior  (totalKwh, avgPower, changePercent)
  ├── Selector de período  (Día / Semana / Mes / Año)
  ├── [solo vista Semana] Selector de día  (Lun–Dom chips)
  ├── Gráfica de barras  (fl_chart, datos de EnergyProvider)
  └── Lista de dispositivos de energía
```

## Períodos

| Período | Agrupación | Eje X |
|---------|-----------|-------|
| Día | Por hora | 0–23 h |
| Semana | Por día (Lun–Dom) | 7 barras |
| Mes | Por día del mes | 28–31 barras |
| Año | Por mes | Ene–Dic |

## Selector de día semanal

Cuando el período es **Semana**, aparece una fila de chips con los 7 días. Al tocar uno:
1. `EnergyProvider.selectWeekDay(index)` guarda el día seleccionado
2. La gráfica filtra `rawWeekHourlyData` para ese día y muestra las horas (0–23)
3. La etiqueta de fecha cambia para mostrar el día específico (ej. `"Martes 20 mayo"`)

Toca el mismo chip de nuevo para volver a la vista semanal completa.

## Etiqueta de fecha dinámica

```
Día     → "22 mayo 2026"
Semana  → "19–25 Mayo 2026"
Mes     → "Mayo 2026"
Año     → "2026"
```

> **Dato curioso:** `rawWeekHourlyData` se guarda en el provider al hacer la llamada semanal, sin una petición extra al backend. El detalle por hora se construye filtrando esos datos en el cliente, lo que hace la navegación entre días instantánea.
