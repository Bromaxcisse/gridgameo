import 'package:flutter/painting.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const _fontFamily = 'ChakraPetch';

  /// Main Titles (Command Terminal)
  /// Chakra Petch Bold, 42sp, Uppercase, tracking +2.0
  static const TextStyle mainTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 42,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: AppColors.textPrimary,
  );

  /// Headers (Sector Titles, Mission Logs)
  /// Chakra Petch SemiBold, 24sp, Uppercase, tracking +1.0
  static const TextStyle header = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.textPrimary,
  );

  /// Body Text (Simulation Guide, Data Integrity)
  /// Chakra Petch Regular, 16sp, Normal case, line-height 1.5
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// HUD / O2 Counter
  /// Chakra Petch Bold, 32sp
  static const TextStyle hud = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.cyanPlasma,
  );

  /// Button labels
  /// Chakra Petch SemiBold, 18sp, Uppercase, tracking +1.0
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.cyanPlasma,
  );

  /// Secondary / muted text
  /// Chakra Petch Regular, 14sp
  static const TextStyle secondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
