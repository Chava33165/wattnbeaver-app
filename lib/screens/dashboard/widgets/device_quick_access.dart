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
    if (devices.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: devices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final device = devices[index];
          final Color domainColor =
              device.isEnergy ? AppColors.mentaMedio : AppColors.cieloMedio;
          final Color domainDark =
              device.isEnergy ? AppColors.mentaOscuro : AppColors.waterDark;

          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.deviceDetail,
              arguments: device,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 96,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: domainColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: domainColor.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Icono con tinte de dominio ──
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          domainColor.withValues(alpha: 0.3),
                          domainColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      device.isEnergy ? Icons.bolt : Icons.water_drop,
                      color: domainDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ── Nombre ──
                  Text(
                    device.deviceName,
                    style: AppTextStyles.chip(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  // ── Estado online/offline ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: device.isOnline
                              ? AppColors.mentaMedio
                              : AppColors.tierra,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        device.isOnline ? 'Online' : 'Offline',
                        style: AppTextStyles.chip(context).copyWith(
                          fontSize: 10,
                          color: device.isOnline
                              ? AppColors.mentaOscuro
                              : AppColors.tierra,
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
