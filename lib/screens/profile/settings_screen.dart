import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/cards/stat_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _alertsEnabled = true;
  bool _weeklyReport = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Configuracion', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOTIFICACIONES',
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            StatCard(
              child: Column(
                children: [
                  _switchTile(
                    'Notificaciones push',
                    'Recibir alertas en tiempo real',
                    _pushNotifications,
                    (v) => setState(() => _pushNotifications = v),
                  ),
                  const Divider(height: 1),
                  _switchTile(
                    'Alertas criticas',
                    'Notificar cuando hay alertas criticas',
                    _alertsEnabled,
                    (v) => setState(() => _alertsEnabled = v),
                  ),
                  const Divider(height: 1),
                  _switchTile(
                    'Reporte semanal',
                    'Recibir resumen semanal de consumo',
                    _weeklyReport,
                    (v) => setState(() => _weeklyReport = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ACERCA DE',
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            StatCard(
              child: Column(
                children: [
                  _infoTile('Version', '1.0.0'),
                  const Divider(height: 1),
                  _infoTile('Backend', 'http://100.69.129.83:3000'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.body),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.energyPrimary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: AppTextStyles.body),
      trailing: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
