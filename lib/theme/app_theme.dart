import 'package:flutter/material.dart';

/// Colors taken from the Internee.pk design (Tailwind palette).
class AppColors {
  static const primary = Color(0xFF4F46E5); // Royal Indigo
  static const purple = Color(0xFF6366F1); // active nav tab / gradient start

  static const secondary = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const blue700 = Color(0xFF1D4ED8);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, primary],
  );

  static const page = Color(0xFFF1F5F9);
  static const bg = Color(0xFFF8FAFC); // app background
  static const border = Color(0xFFE5E7EB); // gray-200
  static const borderSoft = Color(0xFFF3F4F6); // gray-100
  static const inputBorder = Color(0xFFD1D5DB); // gray-300

  static const text = Color(0xFF0F172A); // headings (Slate 900)
  static const textBody = Color(0xFF374151); // gray-700
  static const textMuted = Color(0xFF4B5563); // gray-600
  static const textSoft = Color(0xFF64748B); // secondary labels (Slate 500)
  static const hint = Color(0xFF94A3B8); // inactive nav (Slate 400)
  static const faint = Color(0xFFD1D5DB); // gray-300

  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green700 = Color(0xFF15803D);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber700 = Color(0xFFB45309);
  static const red50 = Color(0xFFFEF2F2);
}

OutlineInputBorder _border(Color color, [double width = 1]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.danger,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.hint),
      border: _border(AppColors.inputBorder),
      enabledBorder: _border(AppColors.inputBorder),
      focusedBorder: _border(AppColors.primary, 2),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, 2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    dividerColor: AppColors.border,
  );
}
