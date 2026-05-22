import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Gotita animada que crece y cambia de azul según los días de racha.
class WaterDropWidget extends StatefulWidget {
  final int streak;
  final int maxStreak;

  const WaterDropWidget({
    super.key,
    required this.streak,
    this.maxStreak = 7,
  });

  @override
  State<WaterDropWidget> createState() => _WaterDropWidgetState();
}

class _WaterDropWidgetState extends State<WaterDropWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _breathe = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _lerp3(Color a, Color b, Color c, double t) {
    if (t <= 0.5) return Color.lerp(a, b, t * 2)!;
    return Color.lerp(b, c, (t - 0.5) * 2)!;
  }

  @override
  Widget build(BuildContext context) {
    final int streak = widget.streak;
    final double level = (streak / widget.maxStreak).clamp(0.0, 1.0);

    final double height = 42.0 + level * 50.0;
    final double width = height * 0.65;

    final Color topColor = _lerp3(
      AppColors.cieloClaro,
      AppColors.cieloMedio,
      AppColors.waterDark,
      level,
    );
    final Color bottomColor = _lerp3(
      AppColors.cieloMedio,
      AppColors.waterDark,
      const Color(0xFF1A5A80),
      level,
    );

    String label;
    if (streak == 0) {
      label = '¡Empieza hoy!';
    } else if (streak >= widget.maxStreak) {
      label = '¡$streak días! 💧';
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
              Icons.water_drop_outlined,
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
                painter: _DropPainter(
                  topColor: topColor,
                  bottomColor: bottomColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.muted(context).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: topColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DropPainter extends CustomPainter {
  final Color topColor;
  final Color bottomColor;

  const _DropPainter({required this.topColor, required this.bottomColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.95, h * 0.38, w * 1.0, h * 0.65, w * 0.5, h);
    path.cubicTo(0, h * 0.65, w * 0.05, h * 0.38, w * 0.5, 0);
    path.close();

    final rect = Rect.fromLTWH(0, 0, w, h);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, bottomColor],
    );

    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = topColor.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Gota principal
    canvas.drawPath(path, Paint()..shader = gradient.createShader(rect));

    // Brillo interior
    final highlightPath = Path();
    highlightPath.moveTo(w * 0.38, h * 0.18);
    highlightPath.cubicTo(
        w * 0.28, h * 0.32, w * 0.27, h * 0.46, w * 0.36, h * 0.56);
    highlightPath.cubicTo(
        w * 0.44, h * 0.48, w * 0.44, h * 0.32, w * 0.38, h * 0.18);
    highlightPath.close();
    canvas.drawPath(
      highlightPath,
      Paint()..color = Colors.white.withValues(alpha: 0.40),
    );
  }

  @override
  bool shouldRepaint(_DropPainter old) =>
      old.topColor != topColor || old.bottomColor != bottomColor;
}
