import 'package:flutter/material.dart';

class AppColors {
  // Cores Oficiais Assistec
  static const Color brandPrimary = Color(0xFF00963A); // rgb(0, 150, 58)
  static const Color brandDark = Color(0xFF093620);    // rgb(9, 54, 32)
  static const Color brandAccent = Color(0xFFF15313);  // rgb(241, 83, 19)
  static const Color brand50 = Color(0xFFE6F4EA);      // Fundo suave de badges ativos
  static const Color brand100 = Color(0xFFCCE9D5);     // Bordas suaves
  static const Color brand200 = Color(0xFF99D3AB);
  static const Color brand300 = Color(0xFF66BD81);
  static const Color brand400 = Color(0xFF33A658);

  // Fundos & Superfícies
  static const Color background = Color(0xFFF8FAFC);   // Slate-50
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);    // Slate-200

  // Tipografia
  static const Color textPrimary = Color(0xFF0F172A);   // Slate-900
  static const Color textMuted = Color(0xFF64748B);     // Slate-500

  // Status & Badges
  static const Color statusSuccess = Color(0xFF00963A);
  static const Color statusSuccessBg = Color(0xFFE6F4EA);
  static const Color statusError = Color(0xFFEF4444);
  static const Color statusErrorBg = Color(0xFFFEE2E2);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusWarningBg = Color(0xFFFEF3C7);
  static const Color statusInfo = Color(0xFF2563EB);
  static const Color statusInfoBg = Color(0xFFDBEAFE);
  static const Color statusPurple = Color(0xFF9333EA);
  static const Color statusPurpleBg = Color(0xFFF3E8FF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandPrimary,
        primary: AppColors.brandPrimary,
        secondary: AppColors.brandAccent,
        surface: AppColors.cardSurface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brandDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
    );
  }
}
