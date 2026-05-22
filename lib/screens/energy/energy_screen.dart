import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/number_formatter.dart';
import '../../providers/devices_provider.dart';
import '../../providers/energy_provider.dart';
import '../../models/device.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/cards/stat_card.dart';

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnergyProvider>().loadEnergy();
      context.read<DevicesProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Energía', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
      ),
      body: Consumer<EnergyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingIndicator();
          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: provider.loadEnergy,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                provider.loadEnergy(period: provider.selectedPeriod),
                context.read<DevicesProvider>().loadDevices(),
              ]);
            },
            color: AppColors.energyPrimary,
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
                  _buildDevicesSection(),
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

  Widget _buildSummaryCards(EnergyProvider provider) {
    final summary = provider.summary;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'POTENCIA ACTUAL',
                value: summary != null
                    ? (summary.onlineDevices > 0
                        ? NumberFormatter.watts(summary.avgPower)
                        : 'Inactivo')
                    : '--',
                icon: Icons.bolt,
                color: summary != null && summary.onlineDevices > 0
                    ? AppColors.energyPrimary
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryTile(
                label: 'CONSUMO ${_periodLabel(provider.selectedPeriod)}',
                value: provider.history != null
                    ? NumberFormatter.kwh(provider.history!.weekTotal)
                    : '--',
                icon: Icons.electric_meter_outlined,
                color: AppColors.energyDark,
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
                    color: AppColors.energyPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.attach_money,
                      color: AppColors.energyPrimary, size: 20),
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
                          (provider.history?.weekTotal ?? 0) * 2.5),
                      style: AppTextStyles.title3
                          .copyWith(color: AppColors.energyPrimary),
                    ),
                  ],
                ),
                const Spacer(),
                Text('\$2.50 / kWh',
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

  Widget _buildPeriodSelector(EnergyProvider provider) {
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
                color: selected
                    ? AppColors.energyPrimary
                    : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(8),
                border: selected
                    ? null
                    : Border.all(color: AppColors.borderSubtle),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.energyPrimary.withValues(alpha: 0.3),
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

  Widget _buildDaySelector(EnergyProvider provider) {
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
                    ? AppColors.energyPrimary
                    : isToday
                        ? AppColors.energyPrimary.withValues(alpha: 0.12)
                        : Colors.transparent,
                border: isToday && !selected
                    ? Border.all(color: AppColors.energyPrimary, width: 1.5)
                    : null,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.energyPrimary.withValues(alpha: 0.35),
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
                                ? AppColors.energyPrimary
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

  List<_ChartSlot> _buildSlots(EnergyProvider provider) {
    final period = provider.selectedPeriod;
    final days = provider.history?.days ?? [];

    if (period == 'day') {
      // Solo datos del día actual
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final Map<String, double> kwhByHour = {};
      for (final d in days) {
        if (!d.date.startsWith(todayStr)) continue;
        final hourKey = d.date.length >= 13 ? d.date.substring(11, 13) : '';
        if (hourKey.isNotEmpty) {
          kwhByHour[hourKey] = (kwhByHour[hourKey] ?? 0.0) + d.totalKwh;
        }
      }
      return List.generate(24, (i) {
        final h = i.toString().padLeft(2, '0');
        return _ChartSlot(label: '$h:00', value: kwhByHour[h] ?? 0.0);
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
      final Map<String, double> kwhByHour = {};
      for (final item in provider.rawWeekHourlyData) {
        final hour = item['hour'] as String? ?? '';
        if (!hour.startsWith(dateStr)) continue;
        final hourKey = hour.length >= 13 ? hour.substring(11, 13) : '';
        if (hourKey.isNotEmpty) {
          final totalEnergy = (item['total_energy'] as num?)?.toDouble()
              ?? ((item['avg_power'] as num?)?.toDouble() ?? 0.0) / 1000.0;
          kwhByHour[hourKey] = (kwhByHour[hourKey] ?? 0.0) + totalEnergy;
        }
      }
      return List.generate(24, (i) {
        final h = i.toString().padLeft(2, '0');
        return _ChartSlot(label: '$h:00', value: kwhByHour[h] ?? 0.0);
      });
    }

    if (period == 'month') {
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final Map<String, double> kwhByDay = {};
      for (final d in days) {
        final dayKey = d.date.length >= 10 ? d.date.substring(8, 10) : '';
        if (dayKey.isNotEmpty) {
          kwhByDay[dayKey] = (kwhByDay[dayKey] ?? 0.0) + d.totalKwh;
        }
      }
      return List.generate(daysInMonth, (i) {
        final day = (i + 1).toString().padLeft(2, '00');
        return _ChartSlot(label: day, value: kwhByDay[day] ?? 0.0);
      });
    }

    if (period == 'year') {
      const abbr = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
      final now = DateTime.now();
      final Map<String, double> kwhByMonth = {};
      for (final d in days) {
        if (d.date.length >= 7) kwhByMonth[d.date] = d.totalKwh;
      }
      return List.generate(12, (i) {
        final monthKey = '${now.year}-${(i + 1).toString().padLeft(2, '00')}';
        return _ChartSlot(label: abbr[i], value: kwhByMonth[monthKey] ?? 0.0);
      });
    }

    // Semana completa — padear con vacíos al inicio si faltan días
    final slots = days.map((d) {
      final label = d.date.length >= 10 ? d.date.substring(5, 10) : d.date;
      return _ChartSlot(label: label, value: d.totalKwh);
    }).toList();

    while (slots.length < 7) {
      slots.insert(0, const _ChartSlot(label: '', value: 0));
    }

    return slots;
  }

  Widget _buildHistoryChart(EnergyProvider provider) {
    final slots = _buildSlots(provider);
    final hasAnyData = slots.any((s) => s.value > 0);

    final isHourlyView = provider.selectedPeriod == 'day' ||
        (provider.selectedPeriod == 'week' && provider.selectedWeekDay != null);

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
                    NumberFormatter.kwh(displayTotal),
                    style: AppTextStyles.title3.copyWith(
                      color: AppColors.energyPrimary,
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
                    tooltipBgColor: AppColors.energyDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = slots[group.x].label;
                      final line1 = label.isNotEmpty ? '$label\n' : '';
                      return BarTooltipItem(
                        '$line1${NumberFormatter.kwh(rod.toY)}',
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
                            AppColors.energyPrimary,
                            AppColors.energyPrimary.withValues(alpha: 0.5),
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

  // ─── Lista de sensores ────────────────────────────────────────────────────────

  Widget _buildDevicesSection() {
    return Consumer<DevicesProvider>(
      builder: (context, devicesProvider, _) {
        final energyDevices = devicesProvider.devices
            .where((d) => d.isEnergy)
            .toList();

        if (energyDevices.isEmpty) return const SizedBox.shrink();

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
            ...energyDevices.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DeviceTile(device: d),
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
          Row(
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
            ],
          ),
          const SizedBox(height: 10),
          Text(label,
              style: AppTextStyles.caption2.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              )),
          const SizedBox(height: 4),
          Text(value,
              style:
                  AppTextStyles.statNumber.copyWith(color: color, fontSize: 22)),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device});
  final Device device;

  @override
  Widget build(BuildContext context) {
    final reading = device.currentReading;
    final online = device.isOnline;
    final power = reading?.power ?? 0.0;
    final voltage = reading?.voltage ?? 0.0;
    final current = reading?.current ?? 0.0;

    return StatCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: online
                  ? AppColors.energyPrimary.withValues(alpha: 0.12)
                  : AppColors.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.electrical_services,
              color: online ? AppColors.energyPrimary : AppColors.textTertiary,
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
                            ? AppColors.energyPrimary
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
                if (online && reading != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${voltage.toStringAsFixed(1)} V  ·  ${current.toStringAsFixed(2)} A',
                    style: AppTextStyles.caption2
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                online ? NumberFormatter.watts(power) : 'Inactivo',
                style: AppTextStyles.title3.copyWith(
                  color: online ? AppColors.energyPrimary : AppColors.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
