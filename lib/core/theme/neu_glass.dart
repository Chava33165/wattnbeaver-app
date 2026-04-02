import 'package:flutter/material.dart';

class NeuGlass {
  // ── CONSTANTES GENERALES ──
  static const double blurGlass = 16.0;
  static const double radiusStandard = 20.0;
  static const double radiusSmall = 12.0;

  // ── GLASSMORPHISM BORDERS & FILLS ──
  static Color glassFill(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.black.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.52);
  }

  static Color glassBorder(BuildContext context) {
    return Colors.white.withValues(alpha: 0.45);
  }

  // ── NEUMORPHISM RAISED ──
  static BoxDecoration neuRaised(BuildContext context,
      {double radius = radiusSmall, Color? baseColor}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg =
        baseColor ?? (isDark ? const Color(0xFF1E293B) : const Color(0xFFECE0D1));

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        // Sombra oscura abajo-derecha
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : const Color(0xFFDBC1AC).withValues(alpha: 0.8),
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
        // Sombra clara arriba-izquierda
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.9),
          offset: const Offset(-4, -4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // ── NEUMORPHISM INSET (presionado) ──
  static BoxDecoration neuInset(BuildContext context,
      {double radius = radiusSmall, Color? baseColor}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg =
        baseColor ?? (isDark ? const Color(0xFF161F2C) : const Color(0xFFE3D5C4));

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : const Color(0xFFDBC1AC).withValues(alpha: 0.5),
        width: 1.5,
      ),
    );
  }
}
