import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/number_formatter.dart';
import '../../providers/devices_provider.dart';
import '../../providers/water_provider.dart';
import '../../models/device.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/cards/stat_card.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterProvider>().loadWater();
      context.read<DevicesProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Agua', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
      ),
      body: Consumer<WaterProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingIndicator();
          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: provider.loadWater,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                provider.loadWater(period: provider.selectedPeriod),
                context.read<DevicesProvider>().loadDevices(),
              ]);
            },
            color: AppColors.waterPrimary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(provider),
                  const SizedBox(height: 20),
                  _buildPeriodSelector(provider),
                  const SizedBox(height: 12),
                  if (provider.selectedPeriod == 'week') ...[
                    _buildDaySelector(provider),
                    const SizedBox(height: 12),
                  ],
                  _buildHistoryChart(provider),
                  const SizedBox(height: 24),
                  _buildSensorsSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static const _meses = [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  static const _diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  String _periodDateLabel(String period) {
    final now = DateTime.now();
    final mes = _meses[now.month];
    if (period == 'month') return '$mes ${now.year}';
    if (period == 'year') return '${now.year}';
    if (period == 'day') return '${now.day} $mes ${now.year}';
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final mesLunes = _meses[monday.month].substring(0, 3);
    final mesDom = _meses[sunday.month].substring(0, 3);
    if (monday.month == sunday.month) {
      return '${monday.day}–${sunday.day} $mesLunes ${now.year}';
    }
    return '${monday.day} $mesLunes – ${sunday.day} $mesDom ${now.year}';
  }

  String _weekDayDateLabel(int dayIndex) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final date = monday.add(Duration(days: dayIndex));
    return '${_diasSemana[dayIndex]} ${date.day} ${_meses[date.month].substring(0, 3)}';
  }

  String _periodLabel(String period) {
    switch (period) {
      case 'day':   return 'HOY';
      case 'month': return 'MES';
      case 'year':  return 'AÑO';
      default:      return 'SEMANA';
    }
  }

  // ─── Resumen ────────────────────────────────────────────────────────────────

  Widget _buildSummaryCards(WaterProvider provider) {
    final summary = provider.summary;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'FLUJO ACTUAL',
                value: summary != null
                    ? (summary.onlineSensors > 0
                        ? '${summary.avgFlow.toStringAsFixed(2)} L/min'
                        : 'Inactivo')
                    : '--',
                icon: Icons.water_drop,
                color: summary != null && summary.onlineSensors > 0
                    ? AppColors.waterPrimary
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryTile(
                label: 'VOLUMEN ${_periodLabel(provider.selectedPeriod)}',
                value: provider.history != null
                    ? NumberFormatter.liters(provider.history!.weekTotal)
                    : '--',
                icon: Icons.opacity,
                color: AppColors.waterDark,
              ),
            ),
          ],
        ),
        if (summary != null) ...[
          const SizedBox(height: 12),
          StatCard(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.waterPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.attach_money,
                      color: AppColors.waterPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COSTO ESTIMADO',
                        style: AppTextStyles.caption2.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.2,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      NumberFormatter.peso(
                          (provider.history?.weekTotal ?? 0) * 0.05),
                      style: AppTextStyles.title3
                          .copyWith(color: AppColors.waterPrimary),
                    ),
                  ],
                ),
                const Spacer(),
                Text('\$0.05 / L',
                    style: AppTextStyles.caption2
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── Selector de período ─────────────────────────────────────────────────────

  Widget _buildPeriodSelector(WaterProvider provider) {
    final periods = {'day': 'Hoy', 'week': 'Semana', 'month': 'Mes', 'year': 'Año'};
    return Row(
      children: periods.entries.map((e) {
        final selected = provider.selectedPeriod == e.key;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => provider.changePeriod(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.waterPrimary : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(8),
                border: selected
                    ? null
                    : Border.all(color: AppColors.borderSubtle),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.waterPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Text(
                e.value,
                style: AppTextStyles.caption1.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Selector de día (solo en vista Semana) ──────────────────────────────────

  Widget _buildDaySelector(WaterProvider provider) {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0=Lun … 6=Dom

    return StatCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final selected = provider.selectedWeekDay == i;
          final isToday = i == todayIndex;
          final isFuture = i > todayIndex;

          return GestureDetector(
            onTap: isFuture
                ? null
                : () => provider.selectWeekDay(selected ? null : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.waterPrimary
                    : isToday
                        ? AppColors.waterPrimary.withValues(alpha: 0.12)
                        : Colors.transparent,
                border: isToday && !selected
                    ? Border.all(color: AppColors.waterPrimary, width: 1.5)
                    : null,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.waterPrimary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : isFuture
                            ? AppColors.textTertiary.withValues(alpha: 0.4)
                            : isToday
                                ? AppColors.waterPrimary
                                : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Gráfica ─────────────────────────────────────────────────────────────────

  List<_ChartSlot> _buildSlots(WaterProvider provider) {
    final period = provider.selectedPeriod;
    final days = provider.history?.days ?? [];

    if (period == 'day') {
      // Solo datos del día actual
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final Map<String, double> litersByHour = {};
      for (final d in days) {
        if (!d.date.startsWith(todayStr)) continue;
        final hourKey = d.date.length >= 13 ? d.date.substring(11, 13) : '';
        if (hourKey.isNotEmpty) {
          litersByHour[hourKey] = (litersByHour[hourKey] ?? 0.0) + d.totalLiters;
        }
      }
      return List.generate(24, (i) {
        final h = i.toString().padLeft(2, '0');
        return _ChartSlot(label: '$h:00', value: litersByHour[h] ?? 0.0);
      });
    }

    // Semana con día seleccionado → gráfica por hora de ese día
    if (period == 'week' && provider.selectedWeekDay != null) {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final selectedDate =
          monday.add(Duration(days: provider.selectedWeekDay!));
      final dateStr =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      final Map<String, double> litersByHour = {};
      for (final item in provider.rawWeekHourlyData) {
        final hour = item['hour'] as String? ?? '';
        if (!hour.startsWith(dateStr)) continue;
        final hourKey = hour.length >= 13 ? hour.substring(11, 13) : '';
        if (hourKey.isNotEmpty) {
          litersByHour[hourKey] = (litersByHour[hourKey] ?? 0.0) +
              ((item['total_volume'] ?? 0) as num).toDouble();
        }
      }
      return List.generate(24, (i) {
        final h = i.toString().padLeft(2, '0');
        return _ChartSlot(label: '$h:00', value: litersByHour[h] ?? 0.0);
      });
    }

    if (period == 'month') {
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final Map<String, double> litersByDay = {};
      for (final d in days) {
        final dayKey = d.date.length >= 10 ? d.date.substring(8, 10) : '';
        if (dayKey.isNotEmpty) {
          litersByDay[dayKey] = (litersByDay[dayKey] ?? 0.0) + d.totalLiters;
        }
      }
      return List.generate(daysInMonth, (i) {
        final day = (i + 1).toString().padLeft(2, '0');
        return _ChartSlot(label: day, value: litersByDay[day] ?? 0.0);
      });
    }

    if (period == 'year') {
      const abbr = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
      final now = DateTime.now();
      final Map<String, double> litersByMonth = {};
      for (final d in days) {
        final monthKey = d.date.length >= 7 ? d.date.substring(0, 7) : '';
        if (monthKey.isEmpty) continue;
        litersByMonth[monthKey] = (litersByMonth[monthKey] ?? 0.0) + d.totalLiters;
      }
      return List.generate(12, (i) {
        final monthKey = '${now.year}-${(i + 1).toString().padLeft(2, '0')}';
        return _ChartSlot(label: abbr[i], value: litersByMonth[monthKey] ?? 0.0);
      });
    }

    // Semana completa — padear con vacíos al inicio si faltan días
    final slots = days.map((d) {
      final label = d.date.length >= 10 ? d.date.substring(5, 10) : d.date;
      return _ChartSlot(label: label, value: d.totalLiters);
    }).toList();

    while (slots.length < 7) {
      slots.insert(0, const _ChartSlot(label: '', value: 0));
    }

    return slots;
  }

  Widget _buildHistoryChart(WaterProvider provider) {
    final slots = _buildSlots(provider);
    final hasAnyData = slots.any((s) => s.value > 0);

    final isHourlyView = provider.selectedPeriod == 'day' ||
        (provider.selectedPeriod == 'week' && provider.selectedWeekDay != null);

    // Total y etiqueta de fecha según la vista
    final double displayTotal = isHourlyView && provider.selectedWeekDay != null
        ? slots.fold(0.0, (s, slot) => s + slot.value)
        : provider.history?.weekTotal ?? 0;

    final String dateLabel = provider.selectedPeriod == 'week' &&
            provider.selectedWeekDay != null
        ? _weekDayDateLabel(provider.selectedWeekDay!)
        : _periodDateLabel(provider.selectedPeriod);

    if (!hasAnyData) {
      return StatCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.bar_chart,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 8),
                Text('Sin datos históricos',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        ),
      );
    }

    final maxVal =
        slots.fold<double>(0.1, (m, s) => s.value > m ? s.value : m);

    final barWidth = isHourlyView
        ? 6.0
        : provider.selectedPeriod == 'month'
            ? 5.0
            : 14.0;

    final step = isHourlyView
        ? 6
        : provider.selectedPeriod == 'month'
            ? 5
            : provider.selectedPeriod == 'year'
                ? 1
                : (slots.length / 4).ceil();

    return StatCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONSUMO',
                      style: AppTextStyles.caption2.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    NumberFormatter.liters(displayTotal),
                    style: AppTextStyles.title3.copyWith(
                      color: AppColors.waterPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                dateLabel,
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.25,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.waterDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = slots[group.x].label;
                      final line1 = label.isNotEmpty ? '$label\n' : '';
                      return BarTooltipItem(
                        '$line1${NumberFormatter.liters(rod.toY)}',
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= slots.length) {
                          return const SizedBox.shrink();
                        }
                        if (i % step != 0 && i != slots.length - 1) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(slots[i].label,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textTertiary)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 3,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFEEEEEE),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(slots.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: slots[i].value,
                        width: barWidth,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.waterPrimary,
                            AppColors.waterPrimary.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sensores ────────────────────────────────────────────────────────────────

  Widget _buildSensorsSection() {
    return Consumer<DevicesProvider>(
      builder: (context, devicesProvider, _) {
        final waterDevices =
            devicesProvider.devices.where((d) => d.isWater).toList();
        if (waterDevices.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'SENSORES',
                style: AppTextStyles.caption2.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...waterDevices.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SensorTile(device: d),
                )),
          ],
        );
      },
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: AppTextStyles.caption2.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.statNumber
                  .copyWith(color: color, fontSize: 22)),
        ],
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  const _SensorTile({required this.device});
  final Device device;

  @override
  Widget build(BuildContext context) {
    final online = device.isOnline;
    return StatCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: online
                  ? AppColors.waterPrimary.withValues(alpha: 0.12)
                  : AppColors.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.water,
              color: online ? AppColors.waterPrimary : AppColors.textTertiary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(device.deviceName,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: online
                            ? AppColors.waterPrimary
                            : AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                if (device.location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(device.location,
                      style: AppTextStyles.caption1
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ],
            ),
          ),
          Text(
            online ? 'En línea' : 'Inactivo',
            style: AppTextStyles.title3.copyWith(
              color: online ? AppColors.waterPrimary : AppColors.textTertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSlot {
  final String label;
  final double value;
  const _ChartSlot({required this.label, required this.value});
}
