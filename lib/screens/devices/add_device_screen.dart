import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/devices_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdCtrl = TextEditingController();
  final _deviceNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _deviceType = 'energy';
  bool _isLoading = false;

  @override
  void dispose() {
    _deviceIdCtrl.dispose();
    _deviceNameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Agregar dispositivo', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _deviceIdCtrl,
                label: 'ID del dispositivo',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _deviceNameCtrl,
                label: 'Nombre',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationCtrl,
                label: 'Ubicacion (opcional)',
              ),
              const SizedBox(height: 16),
              Text('Tipo de dispositivo', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  _typeChip('Energia', 'energy', Icons.bolt,
                      AppColors.energyPrimary),
                  const SizedBox(width: 12),
                  _typeChip('Agua', 'water', Icons.water_drop,
                      AppColors.waterPrimary),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Vincular dispositivo',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String type, IconData icon, Color color) {
    final selected = _deviceType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _deviceType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : AppColors.textTertiary),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption1.copyWith(
                  color: selected ? color : AppColors.textTertiary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<DevicesProvider>().linkDevice(
          deviceId: _deviceIdCtrl.text.trim(),
          deviceName: _deviceNameCtrl.text.trim(),
          deviceType: _deviceType,
          location: _locationCtrl.text.trim().isNotEmpty
              ? _locationCtrl.text.trim()
              : null,
        );

    setState(() => _isLoading = false);

    if (success != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispositivo vinculado correctamente'),
          backgroundColor: AppColors.energyPrimary,
        ),
      );
    } else if (mounted) {
      final error =
          context.read<DevicesProvider>().error ?? 'Error al vincular';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }
}
