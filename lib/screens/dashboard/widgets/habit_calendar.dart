import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../services/api/energy_api.dart';
import '../../../services/api/water_api.dart';
import '../../../widgets/common/loading_indicator.dart';

class HabitCalendar extends StatefulWidget {
  const HabitCalendar({super.key});

  @override
  State<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends State<HabitCalendar> {
  Map<String, double> _energyByDay = {};
  Map<String, double> _waterByDay = {};
  double _energyAvg = 0;
  double _waterAvg = 0;
  bool _loading = true;

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);

    try {
      final results = await Future.wait([
        EnergyApi.getWeeklyStats(
            startDate: _fmt(firstDay), endDate: _fmt(now)),
        WaterApi.getWeeklyStats(
            startDate: _fmt(firstDay), endDate: _fmt(now)),
      ]);

      final energyRows = (results[0]['data'] as List?) ?? [];
      final Map<String, double> emap = {};
      for (final r in energyRows) {
        final date = r['fecha'] as String? ?? '';
        final kwh = (r['consumo_dia_kwh'] as num?)?.toDouble() ?? 0.0;
        if (date.isNotEmpty && kwh > 0) emap[date] = kwh;
      }
      final eavg = emap.isEmpty
          ? 0.0
          : emap.values.reduce((a, b) => a + b) / emap.length;

      final waterRows = (results[1]['data'] as List?) ?? [];
      final Map<String, double> wmap = {};
      for (final r in waterRows) {
        final date = r['fecha'] as String? ?? '';
        final liters = (r['consumo_dia_litros'] as num?)?.toDouble() ?? 0.0;
        if (date.isNotEmpty && liters > 0) wmap[date] = liters;
      }
      final wavg = wmap.isEmpty
          ? 0.0
          : wmap.values.reduce((a, b) => a + b) / wmap.length;

      if (mounted) {
        setState(() {
          _energyByDay = emap;
          _waterByDay = wmap;
          _energyAvg = eavg;
          _waterAvg = wavg;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final offset = firstDay.weekday - 1; // 0=Lun … 6=Dom

    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mis hábitos', style: AppTextStyles.title(context)),
                  Text(
                    months[now.month],
                    style: AppTextStyles.muted(context).copyWith(fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              // ── Leyenda ──
              _LegendItem(
                  color: AppColors.mentaMedio, label: 'Energía'),
              const SizedBox(width: 10),
              _LegendItem(
                  color: AppColors.cieloMedio, label: 'Agua'),
              const SizedBox(width: 10),
              const _StarLegendItem(),
            ],
          ),
          const SizedBox(height: 14),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: LoadingIndicator()),
            )
          else
            _CalendarGrid(
              now: now,
              daysInMonth: daysInMonth,
              offset: offset,
              energyByDay: _energyByDay,
              waterByDay: _waterByDay,
              energyAvg: _energyAvg,
              waterAvg: _waterAvg,
            ),
        ],
      ),
    );
  }
}

// ── Grid del calendario ──
class _CalendarGrid extends StatelessWidget {
  final DateTime now;
  final int daysInMonth;
  final int offset;
  final Map<String, double> energyByDay;
  final Map<String, double> waterByDay;
  final double energyAvg;
  final double waterAvg;

  const _CalendarGrid({
    required this.now,
    required this.daysInMonth,
    required this.offset,
    required this.energyByDay,
    required this.waterByDay,
    required this.energyAvg,
    required this.waterAvg,
  });

  static const _headers = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  String _fmt(int day) =>
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    // Construir lista de celdas: null = vacío, int = número de día
    final List<int?> slots = [
      ...List.filled(offset, null),
      ...List.generate(daysInMonth, (i) => i + 1),
    ];
    // Rellenar hasta múltiplo de 7
    while (slots.length % 7 != 0) { slots.add(null); }

    return Column(
      children: [
        // ── Cabecera días de semana ──
        Row(
          children: _headers
              .map((h) => Expanded(
                    child: Center(
                      child: Text(
                        h,
                        style: AppTextStyles.muted(context)
                            .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),

        // ── Filas de días ──
        for (int row = 0; row < slots.length ~/ 7; row++) ...[
          Row(
            children: List.generate(7, (col) {
              final day = slots[row * 7 + col];
              if (day == null) return const Expanded(child: SizedBox());

              final date = _fmt(day);
              final isFuture = day > now.day;
              final isToday = day == now.day;

              final hasEnergyData = energyByDay.containsKey(date);
              final hasWaterData = waterByDay.containsKey(date);

              final energySaved = !isFuture &&
                  hasEnergyData &&
                  energyAvg > 0 &&
                  energyByDay[date]! < energyAvg;

              final waterSaved = !isFuture &&
                  hasWaterData &&
                  waterAvg > 0 &&
                  waterByDay[date]! < waterAvg;

              final bothSaved = energySaved && waterSaved;

              return Expanded(
                child: _DayCell(
                  day: day,
                  isToday: isToday,
                  isFuture: isFuture,
                  energySaved: energySaved,
                  waterSaved: waterSaved,
                  bothSaved: bothSaved,
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

// ── Celda individual de día ──
class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isFuture;
  final bool energySaved;
  final bool waterSaved;
  final bool bothSaved;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isFuture,
    required this.energySaved,
    required this.waterSaved,
    required this.bothSaved,
  });

  Color _bgColor() {
    if (bothSaved) return const Color(0xFFFFB300).withValues(alpha: 0.18);
    if (energySaved) return AppColors.mentaMedio.withValues(alpha: 0.15);
    if (waterSaved) return AppColors.cieloMedio.withValues(alpha: 0.15);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isFuture
        ? (isDark
            ? Colors.white.withValues(alpha: 0.2)
            : AppColors.tierra.withValues(alpha: 0.25))
        : (isDark ? Colors.white : AppColors.cafeOscuro);

    return SizedBox(
      height: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Círculo del día ──
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgColor(),
              border: isToday
                  ? Border.all(color: AppColors.mentaMedio, width: 1.8)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isToday ? FontWeight.w700 : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),

          // ── Indicadores ──
          SizedBox(
            height: 10,
            child: bothSaved
                ? const Icon(Icons.star_rounded,
                    size: 10, color: Color(0xFFFFB300))
                : (energySaved || waterSaved)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (energySaved) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.mentaMedio,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (waterSaved) const SizedBox(width: 3),
                          ],
                          if (waterSaved)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.cieloMedio,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

// ── Ítem de leyenda con punto de color ──
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label,
            style: AppTextStyles.muted(context).copyWith(fontSize: 9)),
      ],
    );
  }
}

// ── Ítem de leyenda con estrella ──
class _StarLegendItem extends StatelessWidget {
  const _StarLegendItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 9, color: Color(0xFFFFB300)),
        const SizedBox(width: 3),
        Text('Ambas',
            style: AppTextStyles.muted(context).copyWith(fontSize: 9)),
      ],
    );
  }
}
