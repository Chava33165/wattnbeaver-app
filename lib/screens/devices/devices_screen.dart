import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/devices_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/common/empty_state.dart';
import 'widgets/device_card.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevicesProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Dispositivos', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.energyPrimary),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.addDevice);
              if (context.mounted) {
                context.read<DevicesProvider>().loadDevices();
              }
            },
          ),
        ],
      ),
      body: Consumer<DevicesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const LoadingIndicator();
          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: provider.loadDevices,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadDevices,
            color: AppColors.energyPrimary,
            child: Column(
              children: [
                _buildSearchAndFilter(provider),
                Expanded(
                  child: provider.filteredDevices.isEmpty
                      ? const EmptyState(
                          icon: Icons.devices_other,
                          title: 'Sin dispositivos',
                          subtitle: 'Agrega tu primer dispositivo tocando el +',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.filteredDevices.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final device = provider.filteredDevices[i];
                            return DeviceCard(
                              device: device,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.deviceDetail,
                                arguments: device,
                              ),
                              onDelete: () =>
                                  _confirmDelete(context, provider, device.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(DevicesProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            onChanged: provider.setSearch,
            decoration: InputDecoration(
              hintText: 'Buscar dispositivos...',
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textTertiary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Todos', 'all', provider),
                const SizedBox(width: 8),
                _filterChip('Energia', 'energy', provider),
                const SizedBox(width: 8),
                _filterChip('Agua', 'water', provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String type, DevicesProvider provider) {
    final selected = provider.filterType == type;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => provider.setFilter(type),
      selectedColor: AppColors.energyPrimary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.energyPrimary,
      labelStyle: AppTextStyles.caption1.copyWith(
        color: selected ? AppColors.energyPrimary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DevicesProvider provider,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar dispositivo', style: AppTextStyles.title3),
        content: Text('Deseas desvincular este dispositivo?',
            style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
                style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteDevice(id);
    }
  }
}
