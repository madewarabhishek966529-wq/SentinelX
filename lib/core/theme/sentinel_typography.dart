import 'package:flutter/material.dart';
import 'sentinel_colors.dart';

class SentinelTypography {
  SentinelTypography._();

  static const String fontFamily = 'Segoe UI';
  static const String monospaceFamily = 'Consolas';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: SentinelColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: SentinelColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: SentinelColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: SentinelColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: SentinelColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: SentinelColors.textMuted,
  );

  static const TextStyle code = TextStyle(
    fontFamily: monospaceFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: SentinelColors.primary,
  );
}
