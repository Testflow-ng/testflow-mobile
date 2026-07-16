import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

/// Typography extracted from TestFlow website:
/// Headings: Bricolage Grotesque (from Google Fonts)
/// Body: Inter (from Google Fonts)
class AppTypography {
  AppTypography._();

  /// Returns the Bricolage Grotesque font family name for use in fontFamily
  static String get headingFontFamily =>
      GoogleFonts.bricolageGrotesque().fontFamily!;

  /// Returns the Inter font family name for use in fontFamily
  static String get bodyFontFamily => GoogleFonts.inter().fontFamily!;

  static TextTheme buildTextTheme({bool dark = false}) {
    final textColor = dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = dark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return TextTheme(
      // Display - used for splash/hero large text
      displayLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 52,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 52,
        height: 1.05,
        color: textColor,
      ),
      displayMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 42,
        height: 1.05,
        color: textColor,
      ),
      displaySmall: GoogleFonts.bricolageGrotesque(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 36,
        height: 1.1,
        color: textColor,
      ),

      // Heading
      headlineLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 30,
        height: 1.12,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 24,
        height: 1.2,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.bricolageGrotesque(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 20,
        height: 1.3,
        color: textColor,
      ),

      // Title
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 18,
        height: 1.4,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.5,
        color: textColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.01 * 14,
        height: 1.4,
        color: textColor,
      ),

      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.75,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.75,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.01 * 14,
        height: 1.4,
        color: mutedColor,
      ),

      // Label
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01 * 14,
        height: 1.4,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.02 * 12,
        height: 1.5,
        color: mutedColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.02 * 11,
        height: 1.5,
        color: mutedColor,
      ),
    );
  }
}

/// Shadow tokens matching the website's shadow system
class AppShadows {
  AppShadows._();

  /// Soft layered card shadow for borderless light-mode surfaces.
  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.05),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get xs => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: AppDimens.shadowBlurXs,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.08),
      blurRadius: AppDimens.shadowBlurSm,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.08),
      blurRadius: AppDimens.shadowBlurMd,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.12),
      blurRadius: AppDimens.shadowBlurLg,
      offset: const Offset(0, 20),
    ),
  ];

  static List<BoxShadow> get xl => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.16),
      blurRadius: AppDimens.shadowBlurXl,
      offset: const Offset(0, 24),
    ),
  ];

  static List<BoxShadow> primaryGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.25),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];
}
