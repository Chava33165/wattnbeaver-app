import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/device.dart';
import '../../../routes/app_routes.dart';

class DeviceQuickAccess extends StatelessWidget {
  final List<Device> devices;

  const DeviceQuickAccess({super.key, required this.devices});

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: devices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final device = devices[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.deviceDetail,
                arguments: device.id,
              );
            },
            child: Container(
              width: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    device.isEnergy ? Icons.bolt : Icons.water_drop,
                    color: device.isEnergy
                        ? AppColors.energyPrimary
                        : AppColors.waterPrimary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device.deviceName,
                    style: AppTextStyles.caption1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: device.isOnline
                              ? AppColors.energyPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        device.isOnline ? 'Online' : 'Offline',
                        style: AppTextStyles.caption2.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
