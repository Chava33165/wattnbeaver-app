import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/number_formatter.dart';
import '../../providers/energy_provider.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Energia', style: AppTextStyles.title2),
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
            onRefresh: provider.loadEnergy,
            color: AppColors.energyPrimary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(provider),
                  const SizedBox(height: 16),
                  _buildPeriodSelector(provider),
                  const SizedBox(height: 16),
                  _buildHistoryChart(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(EnergyProvider provider) {
    final summary = provider.summary;
    return Row(
      children: [
        Expanded(
          child: StatCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POTENCIA ACTUAL',
                  style: AppTextStyles.caption2.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary != null
                      ? NumberFormatter.watts(summary.avgPower)
                      : '--',
                  style: AppTextStyles.statNumber
                      .copyWith(color: AppColors.energyPrimary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENERGIA TOTAL',
                  style: AppTextStyles.caption2.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary != null ? NumberFormatter.kwh(summary.totalKwh) : '--',
                  style: AppTextStyles.statNumber
                      .copyWith(color: AppColors.energyDark),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(EnergyProvider provider) {
    final periods = ['day', 'week', 'month'];
    final labels = {'day': 'Hoy', 'week': 'Semana', 'month': 'Mes'};
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((period) {
          final selected = provider.selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labels[period]!),
              selected: selected,
              onSelected: (_) => provider.changePeriod(period),
              selectedColor: AppColors.energyPrimary.withValues(alpha: 0.15),
              labelStyle: AppTextStyles.caption1.copyWith(
                color: selected
                    ? AppColors.energyPrimary
                    : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryChart(EnergyProvider provider) {
    final history = provider.history;
    if (history == null || history.days.isEmpty) {
      return StatCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.bar_chart,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 8),
                Text(
                  'Sin datos historicos',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final maxVal = history.days
        .fold<double>(0.1, (m, d) => d.totalKwh > m ? d.totalKwh : m);

    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HISTORIAL DE CONSUMO',
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${NumberFormatter.kwh(history.weekTotal)} total',
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history.days.map((day) {
                final ratio = maxVal > 0 ? day.totalKwh / maxVal : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          day.totalKwh.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio.clamp(0.02, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.energyPrimary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.date.length >= 10
                              ? day.date.substring(5, 10)
                              : day.date,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
