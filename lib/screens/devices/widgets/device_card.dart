import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/device.dart';
import '../../../widgets/cards/stat_card.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isEnergy = device.deviceType == 'energy';
    final color = isEnergy ? AppColors.energyPrimary : AppColors.waterPrimary;

    return StatCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isEnergy ? Icons.bolt : Icons.water_drop,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  device.location.isNotEmpty
                      ? device.location
                      : device.deviceId,
                  style: AppTextStyles.caption1
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: device.isOnline
                      ? AppColors.energyPrimary.withValues(alpha: 0.1)
                      : AppColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  device.isOnline ? 'Activo' : 'Inactivo',
                  style: AppTextStyles.caption2.copyWith(
                    color: device.isOnline
                        ? AppColors.energyPrimary
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.textTertiary, size: 18),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
