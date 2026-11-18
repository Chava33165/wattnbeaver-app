import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  final _newPasswordCtrl    = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm  = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text('Editar perfil', style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    AppColors.gamificationPurple.withValues(alpha: 0.15),
                child: Text(
                  (user?.name.isNotEmpty == true)
                      ? user!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gamificationPurple,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _sectionLabel('Información personal'),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Nombre',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Correo electrónico',
                controller: TextEditingController(text: user?.email ?? ''),
                prefixIcon: Icons.email_outlined,
                enabled: false,
              ),
              const SizedBox(height: 28),
              _sectionLabel('Cambiar contraseña'),
              const SizedBox(height: 4),
              Text(
                'Deja vacío si no deseas cambiarla',
                style: AppTextStyles.caption1
                    .copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Nueva contraseña',
                controller: _newPasswordCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: !_showPassword,
                suffixIcon: IconButton(
                  icon: Icon(_showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Confirmar contraseña',
                controller: _confirmPasswordCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: !_showConfirm,
                suffixIcon: IconButton(
                  icon: Icon(_showConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () =>
                      setState(() => _showConfirm = !_showConfirm),
                ),
                validator: (v) {
                  if (_newPasswordCtrl.text.isEmpty) return null;
                  if (v != _newPasswordCtrl.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Guardar cambios',
                isLoading: auth.isLoading,
                color: AppColors.mentaOscuro,
                onPressed: () => _save(auth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: AppTextStyles.title3.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Future<void> _save(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _newPasswordCtrl.text.isNotEmpty
        ? _newPasswordCtrl.text
        : null;

    final ok = await auth.updateProfile(
      name: _nameCtrl.text,
      password: newPassword,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppColors.mentaOscuro,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Error al actualizar el perfil'),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }
}
