import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/device.dart';
import '../../providers/devices_provider.dart';
import '../../widgets/cards/stat_card.dart';

class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool _rotatingKey = false;
  late Device _device;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments as Device?;
    if (arg != null) _device = arg;
  }

  Future<void> _rotateApiKey() async {
    setState(() => _rotatingKey = true);
    final newKey = await context.read<DevicesProvider>().rotateApiKey(_device.id);
    if (!mounted) return;
    setState(() {
      _rotatingKey = false;
      if (newKey != null) _device = _device.copyWith(apiKey: newKey);
    });
    if (newKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al regenerar la clave')),
      );
    }
  }

  void _showRotateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Regenerar clave'),
        content: const Text(
          'La ESP32 dejará de enviar datos hasta que la reconfigures con la nueva clave.\n\n¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _rotateApiKey();
            },
            child: const Text('Regenerar',
                style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnergy = _device.deviceType == 'energy';
    final color = isEnergy ? AppColors.energyPrimary : AppColors.waterPrimary;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text(_device.deviceName, style: AppTextStyles.title2),
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
                            Text(_device.deviceName,
                                style: AppTextStyles.title3),
                            const SizedBox(height: 4),
                            Text(
                              _device.deviceId,
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
                          color: _device.isOnline
                              ? AppColors.energyPrimary.withValues(alpha: 0.1)
                              : AppColors.textTertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _device.isOnline ? 'Activo' : 'Inactivo',
                          style: AppTextStyles.caption1.copyWith(
                            color: _device.isOnline
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
                      _device.location.isNotEmpty ? _device.location : 'Sin ubicacion'),
                  _infoRow('Estado', _device.status),
                ],
              ),
            ),
            if (_device.currentReading != null) ...[
              const SizedBox(height: 16),
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
                      _statRow('Potencia', '${_device.currentReading!.power.toStringAsFixed(1)} W', color),
                      _statRow('Voltaje', '${_device.currentReading!.voltage.toStringAsFixed(1)} V', color),
                      _statRow('Corriente', '${_device.currentReading!.current.toStringAsFixed(2)} A', color),
                    ],
                  ],
                ),
              ),
            ],
            if (_device.apiKey.isNotEmpty) ...[
              const SizedBox(height: 16),
              StatCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONFIGURACION ESP32',
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'API Key',
                      style: AppTextStyles.caption1
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _device.apiKey,
                              style: AppTextStyles.caption1.copyWith(
                                fontFamily: 'monospace',
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: _device.apiKey));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('API Key copiada')),
                              );
                            },
                            child: Icon(Icons.copy_outlined,
                                size: 20, color: color),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pega esta clave en el portal WiFi de tu ESP32 (192.168.4.1) al configurarla.',
                      style: AppTextStyles.caption1
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _rotatingKey ? null : _showRotateDialog,
                      icon: _rotatingKey
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 18),
                      label: const Text('Regenerar clave'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.alertRed,
                        side: BorderSide(
                            color: AppColors.alertRed.withValues(alpha: 0.5)),
                        minimumSize: const Size.fromHeight(40),
                      ),
                    ),
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
