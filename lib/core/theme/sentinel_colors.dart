import 'package:flutter/material.dart';

/// Design tokens for SentinelX desktop UI:
/// Dark graphite surfaces, restrained cyan/blue accents, and 7 explicit semantic status colors.
class SentinelColors {
  SentinelColors._();

  // Background and Surfaces (Dark Graphite)
  static const Color background = Color(0xFF0B0F17);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceCard = Color(0xFF161F30);
  static const Color surfaceHighlight = Color(0xFF1E293B);
  static const Color border = Color(0xFF263345);
  static const Color borderSubtle = Color(0xFF1F2937);

  // Accents (Restrained Cyan & Sky Blue)
  static const Color primary = Color(0xFF00D2FF);
  static const Color primaryDim = Color(0xFF0284C7);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentBlue = Color(0xFF38BDF8);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Seven Explicit Semantic Status Colors (PRD Requirement)
  // 1. Enabled / Healthy
  static const Color statusEnabled = Color(0xFF10B981); // Emerald
  // 2. Disabled
  static const Color statusDisabled = Color(0xFF94A3B8); // Slate
  // 3. Unknown / Unverified
  static const Color statusUnknown = Color(0xFFF59E0B); // Amber
  // 4. Unsupported
  static const Color statusUnsupported = Color(0xFF64748B); // Cool Gray
  // 5. Access Denied
  static const Color statusAccessDenied = Color(0xFFF43F5E); // Rose
  // 6. Error
  static const Color statusError = Color(0xFFEF4444); // Crimson Red
  // 7. Stale
  static const Color statusStale = Color(0xFFA8A29E); // Stone Gray
}

