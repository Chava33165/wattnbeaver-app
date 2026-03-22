import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/number_formatter.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/cards/stat_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Reportes', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildPeriodSelector(provider),
              Expanded(
                child: _buildBody(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(ReportsProvider provider) {
    final periods = ['daily', 'weekly', 'monthly'];
    final labels = {
      'daily': 'Diario',
      'weekly': 'Semanal',
      'monthly': 'Mensual',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: periods.map((period) {
          final selected = provider.selectedPeriod == period;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(labels[period]!),
                selected: selected,
                onSelected: (_) => provider.loadReport(period: period),
                selectedColor: const Color(0xFF34C759).withValues(alpha: 0.15),
                labelStyle: AppTextStyles.caption1.copyWith(
                  color: selected
                      ? AppColors.energyPrimary
                      : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(ReportsProvider provider) {
    if (provider.isLoading) return const LoadingIndicator();
    if (provider.error != null) {
      return ErrorDisplay(
        message: provider.error!,
        onRetry: provider.loadReport,
      );
    }
    if (provider.reportData == null) {
      return const Center(child: Text('Sin datos'));
    }

    return RefreshIndicator(
      onRefresh: provider.loadReport,
      color: AppColors.energyPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCostSummary(provider),
            const SizedBox(height: 16),
            _buildConsumptionDetails(provider),
            const SizedBox(height: 16),
            _buildTariffInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSummary(ReportsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RESUMEN DE COSTOS',
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Total cost highlight
        StatCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.energyPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.energyPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COSTO TOTAL ESTIMADO',
                    style: AppTextStyles.caption2.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormatter.peso(provider.totalCost),
                    style: AppTextStyles.statNumber
                        .copyWith(color: AppColors.energyPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Energy + Water split
        Row(
          children: [
            Expanded(
              child: StatCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt,
                            color: AppColors.energyPrimary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'ENERGÍA',
                          style: AppTextStyles.caption2.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormatter.peso(provider.energyCost),
                      style: AppTextStyles.title3
                          .copyWith(color: AppColors.energyPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${provider.totalEnergy.toStringAsFixed(2)} kWh',
                      style: AppTextStyles.caption2
                          .copyWith(color: AppColors.textTertiary),
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
                    Row(
                      children: [
                        const Icon(Icons.water_drop,
                            color: AppColors.waterPrimary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'AGUA',
                          style: AppTextStyles.caption2.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormatter.peso(provider.waterCost),
                      style: AppTextStyles.title3
                          .copyWith(color: AppColors.waterPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${provider.totalWater.toStringAsFixed(0)} L',
                      style: AppTextStyles.caption2
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsumptionDetails(ReportsProvider provider) {
    final data = provider.reportData!;
    final periodLabel = {
      'daily': 'hoy',
      'weekly': 'esta semana',
      'monthly': 'este mes',
    }[provider.selectedPeriod]!;

    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONSUMO $periodLabel'.toUpperCase(),
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _consumptionRow(
            icon: Icons.bolt,
            color: AppColors.energyPrimary,
            label: 'Energía',
            value: '${provider.totalEnergy.toStringAsFixed(2)} kWh',
            cost: NumberFormatter.peso(provider.energyCost),
          ),
          const Divider(height: 24),
          _consumptionRow(
            icon: Icons.water_drop,
            color: AppColors.waterPrimary,
            label: 'Agua',
            value: '${provider.totalWater.toStringAsFixed(0)} L',
            cost: NumberFormatter.peso(provider.waterCost),
          ),
          if (_hasComparison(data)) ...[
            const Divider(height: 24),
            _buildComparison(data),
          ],
        ],
      ),
    );
  }

  Widget _consumptionRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String cost,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600)),
            Text(cost,
                style: AppTextStyles.caption1.copyWith(color: color)),
          ],
        ),
      ],
    );
  }

  bool _hasComparison(Map<String, dynamic> data) {
    return data['comparison'] != null || data['totals']?['energy_change'] != null;
  }

  Widget _buildComparison(Map<String, dynamic> data) {
    final comparison = data['comparison'] as Map<String, dynamic>?;
    final energyChange = _extractDouble(
      comparison?['energy_change'] ?? data['totals']?['energy_change'],
    );
    final waterChange = _extractDouble(
      comparison?['water_change'] ?? data['totals']?['water_change'],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VS PERÍODO ANTERIOR',
          style: AppTextStyles.caption2.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _changeChip('Energía', energyChange, AppColors.energyPrimary),
            const SizedBox(width: 8),
            _changeChip('Agua', waterChange, AppColors.waterPrimary),
          ],
        ),
      ],
    );
  }

  Widget _changeChip(String label, double change, Color color) {
    final isPositive = change > 0;
    final displayColor = isPositive ? AppColors.alertRed : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: displayColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${NumberFormatter.percent(change)}',
        style: AppTextStyles.caption1.copyWith(
          color: displayColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTariffInfo() {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                'TARIFAS APLICADAS',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.energyPrimary, size: 16),
              const SizedBox(width: 6),
              Text('Energía:', style: AppTextStyles.body),
              const Spacer(),
              Text('\$2.50 MXN / kWh',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.water_drop,
                  color: AppColors.waterPrimary, size: 16),
              const SizedBox(width: 6),
              Text('Agua:', style: AppTextStyles.body),
              const Spacer(),
              Text('\$0.05 MXN / litro',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  double _extractDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '0') ?? 0.0;
}
