import 'package:flutter/material.dart';

/// App-wide color constants
/// All colors must be defined here and referenced throughout the app
class MyColors {
  MyColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5B4CD6);
  static const Color primaryLight = Color(0xFF8B7EF5);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryDark = Color(0xFFFF4081);
  static const Color secondaryLight = Color(0xFFFF9AC7);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFFE5E9F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // Accent Colors
  static const Color accent = Color(0xFFFBBF24);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x26000000);

  // Premium/Gold Colors
  static const Color premium = Color(0xFFFFD700);
  static const Color premiumDark = Color(0xFFFFB700);
  static const Color premiumLight = Color(0xFFFFE55C);

  // Category Colors (for 11 vocabulary categories)
  static const Color categoryRed = Color(0xFFFF6B6B);
  static const Color categoryOrange = Color(0xFFFF8C42);
  static const Color categoryYellow = Color(0xFFFBBF24);
  static const Color categoryGreen = Color(0xFF34D399);
  static const Color categoryTeal = Color(0xFF14B8A6);
  static const Color categoryBlue = Color(0xFF3B82F6);
  static const Color categoryIndigo = Color(0xFF6366F1);
  static const Color categoryPurple = Color(0xFF8B5CF6);
  static const Color categoryPink = Color(0xFFEC4899);
  static const Color categoryRose = Color(0xFFF43F5E);
  static const Color categoryBrown = Color(0xFFA16207);

  // Splash Screen Gradient Colors
  static const Color splashGradientStart = Color(0xFF2EC4B6);
  static const Color splashGradientEnd = Color(0xFF145C71);

  // Lingola Primary Color
  static const Color lingolaPrimaryColor = Color(0xFF2EC4B6);

  // Splash Screen 2 Colors
  static const Color splashTextPrimary = Color(0xFF1A1A1A);
  static const Color splashTextSecondary = Color(0xFF6B6B6B);
  static const Color splashProgressInactive = Color(0xFFE0E0E0);
  static const Color splashImageBackground = Color(0xFFF5F5F5);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF8B7EF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF9AC7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
