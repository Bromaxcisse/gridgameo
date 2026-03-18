import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const _fontFamily = 'ChakraPetch';

  static ThemeData get darkTheme {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.deepVoid,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.deepVoid,
        primary: AppColors.cyanPlasma,
        secondary: AppColors.neonIsotope,
        error: AppColors.coreBreach,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.deepVoid,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: _fontFamily,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepVoid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.cyanPlasma,
          side: const BorderSide(color: AppColors.cyanPlasma, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          minimumSize: const Size(48, 48),
        ),
      ),
    );
  }
}
