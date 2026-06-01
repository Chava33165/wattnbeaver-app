import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/admin_user.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/cards/stat_card.dart';

class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({super.key});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late AdminUser _user;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _selectedRole;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is AdminUser) {
      _user = arg;
      _nameController = TextEditingController(text: _user.name);
      _emailController = TextEditingController(text: _user.email);
      _selectedRole = _user.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<AdminProvider>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final role = _selectedRole;
    final success = await provider.updateUser(_user.id, {
      'name': name,
      'email': email,
      'role': role,
    });
    if (!mounted) return;
    if (success) {
      setState(() {
        _user = _user.copyWith(name: name, email: email, role: role);
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.operationError ?? 'Error al actualizar')),
      );
    }
  }

  Future<void> _delete() async {
    final provider = context.read<AdminProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar usuario', style: AppTextStyles.title3),
        content: Text(
          '¿Seguro que deseas eliminar a ${_user.name}? Esta acción no se puede deshacer.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: TextStyle(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final success = await provider.deleteUser(_user.id);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.operationError ?? 'Error al eliminar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final provider = context.watch<AdminProvider>();
    final isSelf = _user.id == authProvider.user?.id;
    final avatarColor = _user.isAdmin ? AppColors.energyPrimary : AppColors.gamificationPurple;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: Text(_user.name, style: AppTextStyles.title2),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: provider.isOperating ? null : _save,
              child: provider.isOperating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Guardar',
                      style: TextStyle(color: AppColors.mentaOscuro)),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Text(
                  _user.initials,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: avatarColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _gamStat('${_user.totalPoints}', 'Puntos', AppColors.gamificationPurple)),
                const SizedBox(width: 8),
                Expanded(child: _gamStat('${_user.currentLevel}', 'Nivel', AppColors.energyPrimary)),
                const SizedBox(width: 8),
                Expanded(child: _gamStat('${_user.currentStreak}', 'Racha', AppColors.accentOrange)),
              ],
            ),
            const SizedBox(height: 16),
            StatCard(
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Nombre',
                    controller: _nameController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      onChanged: _isEditing && !isSelf
                          ? (v) => setState(() => _selectedRole = v ?? _selectedRole)
                          : null,
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('Usuario')),
                        DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            StatCard(
              child: Column(
                children: [
                  _infoRow('ID', _user.id),
                  if (_user.createdAt != null) ...[
                    const Divider(height: 20),
                    _infoRow('Creado', DateFormatter.formatDate(_user.createdAt!)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!isSelf)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: provider.isOperating ? null : _delete,
                  icon: const Icon(Icons.delete_outline, color: AppColors.alertRed),
                  label: const Text('Eliminar usuario',
                      style: TextStyle(color: AppColors.alertRed)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.alertRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _gamStat(String value, String label, Color color) {
    return StatCard(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.statNumber.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.caption1.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        Flexible(
          child: Text(value,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
