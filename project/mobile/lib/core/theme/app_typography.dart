import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// CheckGame typography system following brand guidelines
class AppTypography {
  AppTypography._();

  // ============================================================================
  // DISPLAY STYLES (Fredoka - for titles, logos, headlines)
  // ============================================================================

  /// Extra large display text - Game title, splash screen
  static TextStyle get displayLarge => GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.2,
  );

  /// Large display text - Main headings, section titles
  static TextStyle get displayMedium => GoogleFonts.fredoka(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.3,
  );

  /// Medium display text - Sub-headings, card titles
  static TextStyle get displaySmall => GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.darkGrey,
    height: 1.3,
  );

  // ============================================================================
  // HEADLINE STYLES (Fredoka - for prominent UI elements)
  // ============================================================================

  /// Large headline - Page titles, dialog titles
  static TextStyle get headlineLarge => GoogleFonts.fredoka(
    fontSize: 22,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.darkGrey,
    height: 1.4,
  );

  /// Medium headline - Section headers, prominent labels
  static TextStyle get headlineMedium => GoogleFonts.fredoka(
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.darkGrey,
    height: 1.4,
  );

  /// Small headline - Component titles, emphasized text
  static TextStyle get headlineSmall => GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.darkGrey,
    height: 1.4,
  );

  // ============================================================================
  // TITLE STYLES (Quicksand - for UI elements, buttons)
  // ============================================================================

  /// Large title - Button text, tab labels
  static TextStyle get titleLarge => GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.5,
  );

  /// Medium title - Card titles, form labels
  static TextStyle get titleMedium => GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.5,
  );

  /// Small title - Small buttons, chips, badges
  static TextStyle get titleSmall => GoogleFonts.quicksand(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
    height: 1.5,
  );

  // ============================================================================
  // BODY STYLES (Quicksand - for content, descriptions)
  // ============================================================================

  /// Large body text - Main content, important descriptions
  static TextStyle get bodyLarge => GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGrey,
    height: 1.6,
  );

  /// Medium body text - Standard content, card descriptions
  static TextStyle get bodyMedium => GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.mediumGrey,
    height: 1.6,
  );

  /// Small body text - Helper text, captions, metadata
  static TextStyle get bodySmall => GoogleFonts.quicksand(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.lightGrey,
    height: 1.6,
  );

  // ============================================================================
  // LABEL STYLES (Quicksand - for UI labels, form fields)
  // ============================================================================

  /// Large label - Form field labels, prominent tags
  static TextStyle get labelLarge => GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.mediumGrey,
    height: 1.4,
  );

  /// Medium label - Standard labels, navigation items
  static TextStyle get labelMedium => GoogleFonts.quicksand(
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.mediumGrey,
    height: 1.4,
  );

  /// Small label - Tiny labels, timestamps, counters
  static TextStyle get labelSmall => GoogleFonts.quicksand(
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.lightGrey,
    height: 1.4,
  );

  // ============================================================================
  // SPECIALIZED STYLES (for specific use cases)
  // ============================================================================

  /// Game logo style - for branding elements
  static TextStyle get gameLogo => GoogleFonts.fredoka(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  /// Button text style - for all button types
  static TextStyle get buttonText => GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Error text style - for validation messages
  static TextStyle get errorText => GoogleFonts.quicksand(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
    height: 1.4,
  );

  /// Success text style - for positive feedback
  static TextStyle get successText => GoogleFonts.quicksand(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
    height: 1.4,
  );

  // ============================================================================
  // COLOR VARIANTS (helper methods for different text colors)
  // ============================================================================

  /// Apply primary color to any text style
  static TextStyle primary(TextStyle style) =>
      style.copyWith(color: AppColors.primary);

  /// Apply secondary color to any text style
  static TextStyle secondary(TextStyle style) =>
      style.copyWith(color: AppColors.secondary);

  /// Apply white color to any text style (for dark backgrounds)
  static TextStyle onDark(TextStyle style) =>
      style.copyWith(color: AppColors.white);

  /// Apply surface color to any text style
  static TextStyle onPrimary(TextStyle style) =>
      style.copyWith(color: AppColors.surface);
}
