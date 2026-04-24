import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/device.dart';
import '../../providers/devices_provider.dart';
import '../../services/api/energy_api.dart';
import '../../widgets/cards/stat_card.dart';

class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late Device _device;
  bool _rotatingKey = false;
  bool _loadingControl = false;
  bool _refreshing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments as Device?;
    if (arg != null) _device = arg;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDevice());
  }

  Future<void> _refreshDevice() async {
    if (_refreshing || !mounted) return;
    setState(() => _refreshing = true);
    try {
      if (_device.isEnergy) {
        final resp = await EnergyApi.getDevice(_device.deviceId);
        final data = (resp['data'] ?? resp) as Map<String, dynamic>;
        final deviceData = data['device'] ?? data;
        if (deviceData is Map<String, dynamic> && mounted) {
          setState(() => _device = Device.fromJson(deviceData));
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _toggleControl(String action) async {
    setState(() => _loadingControl = true);
    try {
      await EnergyApi.controlDevice(_device.deviceId, action);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              action == 'on' ? 'Dispositivo encendido' : 'Dispositivo apagado'),
          backgroundColor: action == 'on'
              ? AppColors.energyPrimary
              : AppColors.alertRed,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al controlar el dispositivo'),
          backgroundColor: AppColors.alertRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingControl = false);
    }
  }

  Future<void> _rotateApiKey() async {
    setState(() => _rotatingKey = true);
    final newKey =
        await context.read<DevicesProvider>().rotateApiKey(_device.id);
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

  String _relativeTime(DateTime? dt) {
    if (dt == null) return 'Sin datos';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'hace ${diff.inSeconds} seg';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} día${diff.inDays == 1 ? '' : 's'}';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Desconocido';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')} — '
        '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isEnergy = _device.isEnergy;
    final color = isEnergy ? AppColors.energyPrimary : AppColors.waterPrimary;
    final gradientColors =
        isEnergy ? AppColors.energyGradient : AppColors.waterGradient;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: RefreshIndicator(
        onRefresh: _refreshDevice,
        color: color,
        child: CustomScrollView(
          slivers: [
            // ── Hero AppBar ──
            SliverAppBar(
              expandedHeight: 210,
              pinned: true,
              backgroundColor: color,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                _device.deviceName,
                style: AppTextStyles.title2.copyWith(color: Colors.white),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isEnergy ? Icons.bolt : Icons.water_drop,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isEnergy ? 'Sensor de Energía' : 'Sensor de Agua',
                            style: AppTextStyles.caption1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Info general ──
                  _buildInfoCard(color),
                  const SizedBox(height: 16),

                  // ── Lecturas actuales ──
                  _buildReadingsCard(color, isEnergy),
                  const SizedBox(height: 16),

                  // ── Actividad y control ──
                  _buildActivityCard(color, isEnergy),

                  // ── API Key (solo si tiene) ──
                  if (_device.apiKey.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildApiKeyCard(color),
                  ],

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tarjeta: información general ──────────────────────────────────────────
  Widget _buildInfoCard(Color color) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('INFORMACIÓN DEL DISPOSITIVO'),
          const SizedBox(height: 12),
          _infoRow(Icons.memory_outlined, 'ID dispositivo', _device.deviceId),
          _infoRow(
            Icons.location_on_outlined,
            'Ubicación',
            _device.location.isNotEmpty ? _device.location : 'No especificada',
          ),
          _infoRow(Icons.calendar_today_outlined, 'Registrado',
              _formatDate(_device.createdAt)),
          _infoRow(
            _device.isOnline ? Icons.wifi : Icons.wifi_off,
            'Conexión',
            _device.isOnline ? 'En línea' : 'Fuera de línea',
            valueColor: _device.isOnline
                ? AppColors.energyPrimary
                : AppColors.alertRed,
          ),
        ],
      ),
    );
  }

  // ── Tarjeta: lecturas actuales ─────────────────────────────────────────────
  Widget _buildReadingsCard(Color color, bool isEnergy) {
    final r = _device.currentReading;

    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel(
                  isEnergy ? 'LECTURAS ELÉCTRICAS' : 'LECTURAS DE AGUA'),
              if (_refreshing)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: color),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (r == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Icon(Icons.sensors_off,
                        size: 40,
                        color: AppColors.textTertiary.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'Sin lecturas disponibles',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            )
          else if (isEnergy) ...[
            _bigMetric(
              label: 'Potencia actual',
              value: r.power.toStringAsFixed(1),
              unit: 'W',
              color: color,
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                    child: _miniCard(
                        'Voltaje', '${r.voltage.toStringAsFixed(1)} V', color)),
                const SizedBox(width: 12),
                Expanded(
                    child: _miniCard('Corriente',
                        '${r.current.toStringAsFixed(2)} A', color)),
              ],
            ),
            if (r.energy > 0) ...[
              const Divider(height: 28),
              _bigMetric(
                label: 'Energía acumulada',
                value: r.energy.toStringAsFixed(3),
                unit: 'kWh',
                color: color,
              ),
            ],
          ] else ...[
            _bigMetric(
              label: 'Flujo actual',
              value: r.flow.toStringAsFixed(2),
              unit: 'L/min',
              color: color,
            ),
            const Divider(height: 28),
            _bigMetric(
              label: 'Volumen total acumulado',
              value: r.total.toStringAsFixed(1),
              unit: 'L',
              color: color,
            ),
          ],
        ],
      ),
    );
  }

  // ── Tarjeta: actividad y control ──────────────────────────────────────────
  Widget _buildActivityCard(Color color, bool isEnergy) {
    final ts = _device.currentReading?.timestamp;

    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ACTIVIDAD'),
          const SizedBox(height: 12),
          _infoRow(Icons.access_time_outlined, 'Última lectura',
              _relativeTime(ts)),
          _infoRow(
            _device.isOnline
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            _device.isOnline ? 'Estado' : 'Último encendido',
            _device.isOnline ? 'Activo ahora' : _relativeTime(ts),
            valueColor: _device.isOnline
                ? AppColors.energyPrimary
                : AppColors.textTertiary,
          ),
          if (ts != null)
            _infoRow(Icons.schedule_outlined, 'Timestamp exacto',
                _formatTimestamp(ts)),

          if (isEnergy) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _sectionLabel('CONTROL REMOTO'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _loadingControl ? null : () => _toggleControl('on'),
                    icon: _loadingControl
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.power_settings_new, size: 18),
                    label: const Text('Encender'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.energyPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _loadingControl ? null : () => _toggleControl('off'),
                    icon: const Icon(Icons.power_off_outlined, size: 18),
                    label: const Text('Apagar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.alertRed,
                      minimumSize: const Size.fromHeight(42),
                      side: BorderSide(
                          color: AppColors.alertRed.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Tarjeta: API Key ESP32 ────────────────────────────────────────────────
  Widget _buildApiKeyCard(Color color) {
    return StatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('CONFIGURACIÓN ESP32'),
          const SizedBox(height: 12),
          Text(
            'API Key',
            style:
                AppTextStyles.caption1.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
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
                    Clipboard.setData(ClipboardData(text: _device.apiKey));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API Key copiada')),
                    );
                  },
                  child: Icon(Icons.copy_outlined, size: 20, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
              minimumSize: const Size.fromHeight(40),
              side: BorderSide(
                  color: AppColors.alertRed.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
        text,
        style: AppTextStyles.caption1.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(label,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textTertiary)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigMetric(
      {required String label,
      required String value,
      required String unit,
      required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.caption1.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTextStyles.statNumber
                  .copyWith(color: color, height: 1.1),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                unit,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption1
                  .copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
