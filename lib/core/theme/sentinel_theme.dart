import 'package:flutter/material.dart';
import 'sentinel_colors.dart';
import 'sentinel_typography.dart';

class SentinelTheme {
  SentinelTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SentinelColors.background,
      fontFamily: SentinelTypography.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: SentinelColors.primary,
        secondary: SentinelColors.accentCyan,
        surface: SentinelColors.surface,
        error: SentinelColors.statusError,
        onPrimary: SentinelColors.background,
        onSurface: SentinelColors.textPrimary,
        outline: SentinelColors.border,
      ),
      cardTheme: CardThemeData(
        color: SentinelColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: SentinelColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: SentinelColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SentinelColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: SentinelColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: SentinelColors.border),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          color: SentinelColors.textPrimary,
        ),
        waitDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
