import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/text_styles.dart';

/// Flamita animada que crece y cambia de color según los días de racha.
/// Racha baja → pequeña y amarilla. Racha alta → grande y morada.
class FlameWidget extends StatefulWidget {
  final int streak;
  final int maxStreak;

  const FlameWidget({
    super.key,
    required this.streak,
    this.maxStreak = 7,
  });

  @override
  State<FlameWidget> createState() => _FlameWidgetState();
}

class _FlameWidgetState extends State<FlameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _wobble;
  late Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    _wobble = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _breathe = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Interpola entre 3 colores en el rango [0, 1]
  Color _lerp3(Color a, Color b, Color c, double t) {
    if (t <= 0.5) return Color.lerp(a, b, t * 2)!;
    return Color.lerp(b, c, (t - 0.5) * 2)!;
  }

  @override
  Widget build(BuildContext context) {
    final int streak = widget.streak;
    final double level =
        (streak / widget.maxStreak).clamp(0.0, 1.0);

    // Tamaño crece con la racha: 42px → 92px de alto
    final double height = 42.0 + level * 50.0;
    final double width = height * 0.62;

    // Colores: amarillo → naranja → morado
    final Color baseColor = _lerp3(
      const Color(0xFFFFD600),
      const Color(0xFFFF5E00),
      const Color(0xFF9B44D6),
      level,
    );
    final Color tipColor = _lerp3(
      const Color(0xFFFF9A00),
      const Color(0xFFE0206A),
      const Color(0xFF4B0D93),
      level,
    );

    String label;
    if (streak == 0) {
      label = '¡Empieza hoy!';
    } else if (streak >= widget.maxStreak) {
      label = '¡$streak días! 🌟';
    } else {
      label = '$streak ${streak == 1 ? 'día' : 'días'}';
    }

    if (streak == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 38,
              color: Colors.grey.withValues(alpha: 0.28),
            ),
            const SizedBox(height: 5),
            Text(
              '¡Empieza hoy!',
              style: AppTextStyles.muted(context).copyWith(fontSize: 10),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _breathe.value,
              child: CustomPaint(
                size: Size(width, height),
                painter: _FlamePainter(
                  wobble: _wobble.value,
                  baseColor: baseColor,
                  tipColor: tipColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.muted(context).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: baseColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FlamePainter extends CustomPainter {
  final double wobble; // -1.0 a 1.0
  final Color baseColor;
  final Color tipColor;

  const _FlamePainter({
    required this.wobble,
    required this.baseColor,
    required this.tipColor,
  });

  Path _buildPath(Size size) {
    final w = size.width;
    final h = size.height;
    // Cuánto se desplaza la punta horizontalmente
    final shift = wobble * w * 0.07;

    final path = Path();

    // Base: centro inferior
    path.moveTo(w * 0.5, h);

    // Lado izquierdo subiendo
    path.cubicTo(
      w * 0.10, h * 0.86,
      w * 0.04, h * 0.52,
      w * 0.26, h * 0.30,
    );
    // Hombro izquierdo → punta (oscila)
    path.cubicTo(
      w * 0.33, h * 0.15,
      w * 0.42 + shift, h * 0.04,
      w * 0.50 + shift * 0.5, 0, // punta
    );
    // Punta → hombro derecho
    path.cubicTo(
      w * 0.58 + shift, h * 0.04,
      w * 0.67, h * 0.15,
      w * 0.74, h * 0.30,
    );
    // Lado derecho bajando
    path.cubicTo(
      w * 0.96, h * 0.52,
      w * 0.90, h * 0.86,
      w * 0.5, h,
    );

    path.close();
    return path;
  }

  // Llama interior más pequeña para dar profundidad
  Path _buildInnerPath(Size size) {
    final w = size.width * 0.44;
    final h = size.height * 0.55;
    final ox = (size.width - w) / 2 + wobble * size.width * 0.03;
    final oy = size.height * 0.3;

    final path = Path();
    path.moveTo(ox + w * 0.5, oy + h);
    path.cubicTo(
      ox + w * 0.1, oy + h * 0.8,
      ox + w * 0.05, oy + h * 0.45,
      ox + w * 0.28, oy + h * 0.25,
    );
    path.cubicTo(
      ox + w * 0.38, oy + h * 0.08,
      ox + w * 0.5, oy,
      ox + w * 0.5, oy,
    );
    path.cubicTo(
      ox + w * 0.5, oy,
      ox + w * 0.62, oy + h * 0.08,
      ox + w * 0.72, oy + h * 0.25,
    );
    path.cubicTo(
      ox + w * 0.95, oy + h * 0.45,
      ox + w * 0.9, oy + h * 0.8,
      ox + w * 0.5, oy + h,
    );
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Halo / glow exterior
    canvas.drawPath(
      path,
      Paint()
        ..color = baseColor.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
    );

    // 2. Llama principal con gradiente
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.white.withValues(alpha: 0.92),
        baseColor,
        tipColor,
      ],
      stops: const [0.0, 0.28, 1.0],
    );
    canvas.drawPath(
      path,
      Paint()..shader = gradient.createShader(rect),
    );

    // 3. Llama interior más clara (núcleo)
    final innerPath = _buildInnerPath(size);
    final innerRect = Rect.fromLTWH(0, size.height * 0.25,
        size.width, size.height * 0.75);
    final innerGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.white.withValues(alpha: 0.85),
        Colors.white.withValues(alpha: 0.4),
        Colors.white.withValues(alpha: 0.0),
      ],
    );
    canvas.drawPath(
      innerPath,
      Paint()..shader = innerGradient.createShader(innerRect),
    );
  }

  @override
  bool shouldRepaint(_FlamePainter old) =>
      old.wobble != wobble ||
      old.baseColor != baseColor ||
      old.tipColor != tipColor;
}

// Cálculo de racha a partir de datos semanales diarios
// dataMap: weekday 0=Lun .. 6=Dom → valor
// Devuelve días consecutivos hasta hoy donde val < avg
int calcFlameStreak(Map<int, double> dataMap, double avg) {
  if (avg == 0 || dataMap.isEmpty) return 0;
  final todayIdx = DateTime.now().weekday - 1;
  int streak = 0;
  for (int i = todayIdx; i >= 0; i--) {
    final val = dataMap[i];
    if (val == null || val == 0 || val >= avg) break;
    streak++;
  }
  return streak;
}

// Construye mapa weekday→valor desde lista de fechas ISO
// Usable tanto para energía como agua
Map<int, double> buildWeekdayMap(
    List<({String date, double value})> entries) {
  final Map<int, double> map = {};
  for (final e in entries) {
    final dt = DateTime.tryParse(e.date);
    if (dt != null) map[dt.weekday - 1] = e.value;
  }
  return map;
}

// Extensión práctica para generar offset de puntos sin importar el tipo
extension FlameAngle on double {
  double get rad => this * math.pi / 180;
}
