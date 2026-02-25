import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/device.dart';
import '../../widgets/cards/stat_card.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final device = ModalRoute.of(context)?.settings.arguments as Device?;

    if (device == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Dispositivo', style: AppTextStyles.title2)),
        body: const Center(child: Text('Dispositivo no encontrado')),
      );
    }

    final isEnergy = device.deviceType == 'energy';
    final color = isEnergy ? AppColors.energyPrimary : AppColors.waterPrimary;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text(device.deviceName, style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StatCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isEnergy ? Icons.bolt : Icons.water_drop,
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(device.deviceName,
                                style: AppTextStyles.title3),
                            const SizedBox(height: 4),
                            Text(
                              device.deviceId,
                              style: AppTextStyles.caption1.copyWith(
                                  color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: device.isOnline
                              ? AppColors.energyPrimary.withValues(alpha: 0.1)
                              : AppColors.textTertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          device.isOnline ? 'Activo' : 'Inactivo',
                          style: AppTextStyles.caption1.copyWith(
                            color: device.isOnline
                                ? AppColors.energyPrimary
                                : AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  _infoRow('Tipo',
                      isEnergy ? 'Energia electrica' : 'Agua'),
                  _infoRow('Ubicacion',
                      device.location.isNotEmpty ? device.location : 'Sin ubicacion'),
                  _infoRow('Estado', device.status),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (device.currentReading != null) ...[
              StatCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ULTIMA LECTURA',
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isEnergy) ...[
                      _statRow('Potencia', '${device.currentReading!.power.toStringAsFixed(1)} W', color),
                      _statRow('Voltaje', '${device.currentReading!.voltage.toStringAsFixed(1)} V', color),
                      _statRow('Corriente', '${device.currentReading!.current.toStringAsFixed(2)} A', color),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.body.copyWith(color: AppColors.textTertiary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
