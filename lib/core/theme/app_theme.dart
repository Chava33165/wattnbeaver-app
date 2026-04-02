import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.crema,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mentaMedio,
        secondary: AppColors.cieloMedio,
        error: AppColors.coralIntenso,
        surface: AppColors.crema,
      ),
      fontFamily: 'Nunito',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.cafeOscuro,
        ),
        iconTheme: const IconThemeData(color: AppColors.cafeOscuro),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.mentaMedio,
        unselectedItemColor: AppColors.tierra,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.mentaProfundo,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mentaMedio,
        secondary: AppColors.cieloMedio,
        error: AppColors.coralIntenso,
        surface: Color(0xFF161F2C),
      ),
      fontFamily: 'Nunito',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.mentaMedio,
        unselectedItemColor: Color(0xFF9A9490),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
