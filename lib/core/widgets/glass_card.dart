import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/neu_glass.dart';
import '../constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool accent;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.accent = false,
    this.blur = NeuGlass.blurGlass,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color accentColor = isDark
        ? AppColors.mentaMedio.withValues(alpha: 0.15)
        : AppColors.mentaClaro.withValues(alpha: 0.3);

    return ClipRRect(
      borderRadius: BorderRadius.circular(NeuGlass.radiusStandard),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: accent ? accentColor : NeuGlass.glassFill(context),
            borderRadius: BorderRadius.circular(NeuGlass.radiusStandard),
            border: Border.all(
              color: NeuGlass.glassBorder(context),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
