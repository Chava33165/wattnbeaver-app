import 'package:flutter/material.dart';

class AppColors {
  // ── PALETA A: Verdes Menta (Identidad WattBeaber) ──
  static const Color mentaClaro = Color(0xFFA8F0D0);
  static const Color mentaMedio = Color(0xFF52BF90);
  static const Color mentaBase = Color(0xFF419873);
  static const Color mentaOscuro = Color(0xFF317256);
  static const Color mentaProfundo = Color(0xFF1A3D2E);

  // ── PALETA B: Cremas y Cafés Cálidos (Neutros) ──
  static const Color crema = Color(0xFFECE0D1);
  static const Color arena = Color(0xFFDBC1AC);
  static const Color tierra = Color(0xFF967259);
  static const Color cafe = Color(0xFF634832);
  static const Color cafeOscuro = Color(0xFF38220F);

  // ── PALETA C: Acentos Pasteles Vivos ──
  static const Color lavandaClaro = Color(0xFFC4A8FF);
  static const Color lavandaMedio = Color(0xFF9B79FF);
  
  static const Color cieloClaro = Color(0xFF72D0F0);
  static const Color cieloMedio = Color(0xFF4AB8E0);
  
  static const Color coralClaro = Color(0xFFFF8B6A);
  static const Color coralIntenso = Color(0xFFFF6B4A);
  
  static const Color duraznoClaro = Color(0xFFFFB085);
  static const Color duraznoMedio = Color(0xFFFF8F5E);

  // ── DEGRADADOS APROBADOS ──
  static const LinearGradient fondoModoOscuro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A3D2E), 
      Color(0xFF0D2137), 
      Color(0xFF1A1A3E), 
    ],
  );

  static const LinearGradient fondoModoClaro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      crema,
      arena,
      mentaClaro,
    ],
  );

  static const LinearGradient cardElectrica = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mentaClaro, mentaMedio],
  );

  static const LinearGradient cardHidrica = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cieloClaro, cieloMedio],
  );

  static const LinearGradient cardLogro = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lavandaClaro, lavandaMedio],
  );

  static const LinearGradient botonAccion = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mentaMedio, mentaOscuro],
  );

  static const LinearGradient barraProgreso = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [mentaClaro, mentaMedio, mentaOscuro],
  );


  // ── BACKWARD COMPATIBILITY (Fijando los errores del resto de la app) ──
  // Domain colors
  static const Color energyPrimary  = mentaMedio;
  static const Color energyLight    = mentaClaro;
  static const Color energyDark     = mentaOscuro;

  static const Color waterPrimary   = cieloMedio;
  static const Color waterLight     = cieloClaro;
  static const Color waterDark      = Color(0xFF2C84A8);

  static const Color alertRed       = coralIntenso;
  static const Color gamificationPurple = lavandaMedio;

  static const Color accentOrange   = duraznoMedio;
  static const Color accentYellow   = Color(0xFFFFCC00);

  // Backgrounds
  static const Color backgroundPrimary   = crema;
  static const Color backgroundSecondary = arena;
  static const Color backgroundTertiary  = Color(0xFFE6D6C4);

  static const Color cardSurface = Colors.white24;

  static const Color borderSubtle = Colors.white30;
  static const Color borderMedium = Colors.white54;

  static const Color darkPrimary   = mentaProfundo;
  static const Color darkSecondary = Color(0xFF0D2137);
  static const Color darkTertiary  = Color(0xFF1A1A3E);

  // Text
  static const Color textPrimary   = cafeOscuro;
  static const Color textSecondary = cafe;
  static const Color textTertiary  = tierra;

  // Gradients
  static const List<Color> energyGradient = [mentaClaro, mentaMedio];
  static const List<Color> waterGradient = [cieloClaro, cieloMedio];
  static const List<Color> gamificationGradient = [lavandaClaro, lavandaMedio];
}
