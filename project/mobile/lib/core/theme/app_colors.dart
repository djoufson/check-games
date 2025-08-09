import 'package:flutter/material.dart';

/// CheckGame brand colors following the Modern Afro-Fusion palette
class AppColors {
  AppColors._();

  // ============================================================================
  // PRIMARY BRAND COLORS
  // ============================================================================

  /// Bright Mango - Primary accent/action color
  static const Color brightMango = Color(0xFFFF9F1C);

  /// Tropical Teal - Secondary accent/success color
  static const Color tropicalTeal = Color(0xFF2EC4B6);

  /// Warm Coral - Warning/highlight color
  static const Color warmCoral = Color(0xFFE76F51);

  /// Soft Sand - Background/neutral color
  static const Color softSand = Color(0xFFF4E1D2);

  // ============================================================================
  // SEMANTIC COLORS (using brand colors for consistent theming)
  // ============================================================================

  /// Primary action color (buttons, links, active states)
  static const Color primary = brightMango;

  /// Secondary action color (secondary buttons, accents)
  static const Color secondary = tropicalTeal;

  /// Success color (success messages, positive feedback)
  static const Color success = tropicalTeal;

  /// Warning/Error color (warnings, errors, destructive actions)
  static const Color error = warmCoral;

  /// Surface color (cards, containers, elevated surfaces)
  static const Color surface = softSand;

  // ============================================================================
  // NEUTRAL COLORS (complementing the brand palette)
  // ============================================================================

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black
  static const Color black = Color(0xFF000000);

  /// Light grey for subtle text
  static const Color lightGrey = Color(0xFF9E9E9E);

  /// Medium grey for secondary text
  static const Color mediumGrey = Color(0xFF616161);

  /// Dark grey for primary text
  static const Color darkGrey = Color(0xFF424242);

  // ============================================================================
  // GRADIENT COLORS (for modern UI elements)
  // ============================================================================

  /// Primary gradient (Bright Mango to Warm Coral)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brightMango, warmCoral],
  );

  /// Secondary gradient (Tropical Teal to Bright Mango)
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tropicalTeal, brightMango],
  );

  /// Soft gradient (Soft Sand to White)
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softSand, white],
  );

  // ============================================================================
  // OPACITY VARIANTS (for overlays and disabled states)
  // ============================================================================

  /// Primary color with opacity for disabled states
  static Color primaryDisabled = brightMango.withValues(alpha: 0.5);

  /// Surface color with opacity for overlays
  static Color surfaceOverlay = softSand.withValues(alpha: 0.8);

  /// Black overlay for modals
  static Color blackOverlay = black.withValues(alpha: 0.6);
}
