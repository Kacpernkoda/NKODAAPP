import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accentRed,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentRed,
        secondary: AppColors.accentRed,
        surface: AppColors.cardBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(color: AppColors.textWhite, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: AppColors.textSilver),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSilver),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pureBlack,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureBlack,
        selectedItemColor: AppColors.accentRed,
        unselectedItemColor: AppColors.textSilver,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentRed,
          foregroundColor: AppColors.textWhite,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        elevation: 0,
      ),
    );
  }
}
