import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // ── BASE CONFIGURATION ──
  static TextStyle _nunito(
    double size,
    FontWeight weight, {
    Color? color,
    double? opacity,
    double? letterSpacing,
    double? height,
  }) {
    TextStyle style = GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
    if (opacity != null) {
      return style.copyWith(color: style.color?.withValues(alpha: opacity));
    }
    return style;
  }

  static TextStyle _inter(
    double size,
    FontWeight weight, {
    Color? color,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // ── ESCALA TIPOGRÁFICA NUEVA (Neu Glass System) ──
  static TextStyle display(BuildContext context, {Color? color}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return _inter(32, FontWeight.w700, color: color ?? (isDark ? Colors.white : const Color(0xFF1A3D2E)));
  }

  static TextStyle title(BuildContext context, {Color? color}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return _nunito(18, FontWeight.w600, color: color ?? (isDark ? const Color(0xFFECE0D1) : const Color(0xFF317256)));
  }

  // Renamed to neuBody to avoid conflict with the old getter `body`
  static TextStyle neuBody(BuildContext context, {Color? color}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return _nunito(14, FontWeight.w400, color: color ?? (isDark ? const Color(0xFFECE0D1) : const Color(0xFF634832)), opacity: 0.85);
  }

  static TextStyle muted(BuildContext context, {Color? color}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return _nunito(12, FontWeight.w400, color: color ?? (isDark ? const Color(0xFFECE0D1) : const Color(0xFF634832)), opacity: 0.55);
  }

  static TextStyle chip(BuildContext context, {Color? color}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return _nunito(11, FontWeight.w600, color: color ?? (isDark ? Colors.white : const Color(0xFF38220F)));
  }

  // ── BACKWARD COMPATIBILITY (Arreglando errores en el resto de la app) ──
  // Devuelve TextStyles planos sin depender del context para las pantallas viejas.
  static TextStyle get largeTitle  => _nunito(34, FontWeight.w700, letterSpacing: 0.37);
  static TextStyle get title1      => _nunito(28, FontWeight.w700, letterSpacing: 0.36);
  static TextStyle get title2      => _nunito(22, FontWeight.w700, letterSpacing: 0.35);
  static TextStyle get title3      => _nunito(20, FontWeight.w600, letterSpacing: 0.38);

  static TextStyle get body        => _nunito(16, FontWeight.w400, letterSpacing: -0.2, height: 1.5);
  static TextStyle get bodyMedium  => _nunito(14, FontWeight.w400, letterSpacing: -0.1, height: 1.5);

  static TextStyle get displayNumber => _inter(48, FontWeight.w700);
  static TextStyle get statNumber    => _inter(32, FontWeight.w600);

  static TextStyle get caption1 => _nunito(12, FontWeight.w400);
  static TextStyle get caption2 => _nunito(11, FontWeight.w400);
}
