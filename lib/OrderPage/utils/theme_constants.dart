import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

/// ThemeConstants provides central styling tokens, typography, and palette shortcuts
/// for Durvasa Ayurved with the brand's signature deep Ayurvedic green & warm gold aesthetic.
class ThemeConstants {
  ThemeConstants._();

  // ============================================================
  // BRAND COLOR TOKENS
  // ============================================================
  static const Color primary = AppColors.primaryGreen;
  static const Color primaryColor = AppColors.primaryGreen;
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color primaryLight = AppColors.secondaryGreen;
  static const Color secondaryGreen = AppColors.secondaryGreen;
  static const Color darkGreen = AppColors.darkGreen;
  static const Color leafGreen = AppColors.leafGreen;

  static const Color accentColor = AppColors.primaryGold;
  static const Color primaryGold = AppColors.primaryGold;
  static const Color lightGold = AppColors.lightGold;
  static const Color deepGold = AppColors.deepGold;

  static const Color backgroundColor = AppColors.creamBackground;
  static const Color creamBackground = AppColors.creamBackground;
  static const Color cream = AppColors.cream;
  static const Color surfaceColor = AppColors.white;
  static const Color white = AppColors.white;

  // Text Colors
  static const Color textPrimary = AppColors.textDark;
  static const Color textDark = AppColors.textDark;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textPrice = AppColors.primaryGreen;

  // Status Colors
  static const Color error = AppColors.error;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;

  // ============================================================
  // SPACING & SIZING
  // ============================================================
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusXLarge = 28.0;

  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // ============================================================
  // TYPOGRAPHY (POPPINS FONT)
  // ============================================================
  static TextStyle headingStyle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle subheadingStyle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle bodyStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle captionStyle = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle priceStyle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: textPrice,
  );

  // ============================================================
  // CARD & CONTAINER DECORATIONS
  // ============================================================
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    border: Border.all(color: primaryGold.withOpacity(0.25)),
    boxShadow: [
      BoxShadow(
        color: primaryGreen.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration luxuryGradientDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [darkGreen, primaryGreen],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    border: Border.all(color: primaryGold.withOpacity(0.35), width: 1.2),
    boxShadow: [
      BoxShadow(
        color: primaryGreen.withOpacity(0.25),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

