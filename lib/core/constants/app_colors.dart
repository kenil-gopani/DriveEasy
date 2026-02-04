import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Teal/Dark Blue theme
  static const Color primary = Color(0xFF1A3A4A);
  static const Color primaryLight = Color(0xFF2D5A6A);
  static const Color primaryDark = Color(0xFF0D2530);

  // Secondary/Accent Colors - Coral/Salmon
  static const Color accent = Color(0xFFE85A4F);
  static const Color accentLight = Color(0xFFFF7B6F);
  static const Color accentDark = Color(0xFFD04538);

  // Teal accent
  static const Color teal = Color(0xFF4ECDC4);
  static const Color tealLight = Color(0xFF7EDDD6);
  static const Color tealDark = Color(0xFF3DBDB5);

  // Background Colors - Light
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF0F4F8);

  // Background Colors - Dark (AMOLED)
  static const Color darkBackground = Color(0xFF000000); // Pure Black
  static const Color darkSurface = Color(
    0xFF1C1C1E,
  ); // Apple-style Dark Surface
  static const Color darkCardBackground = Color(
    0xFF2C2C2E,
  ); // Slightly lighter for contrast
  static const Color darkScaffoldBackground = Color(0xFF000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A2B3C);
  static const Color textSecondary = Color(0xFF6B7D8A);
  static const Color textLight = Color(0xFF9EAAB4);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0D1B2A);

  // Text Colors - Dark Mode
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFEBEBF5); // 60% White
  static const Color darkTextMuted = Color(0xFF8E8E93);

  // Dark Mode Accents (New Premium Look)
  static const Color darkPrimary = Color(0xFF0A84FF); // iOS System Blue
  static const Color darkAccent = Color(0xFF5E5CE6); // Indigo shade
  static const Color darkError = Color(0xFFFF453A);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE85A4F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Badge Colors
  static const Color badgeNew = Color(0xFF4ECDC4);
  static const Color badgeUsed = Color(0xFFFF9800);
  static const Color badgePromoted = Color(0xFF9C27B0);
  static const Color badgeFeatured = Color(0xFFE85A4F);

  // Booking Status Colors
  static const Color pending = Color(0xFFFF9800);
  static const Color confirmed = Color(0xFF4CAF50);
  static const Color cancelled = Color(0xFFE85A4F);
  static const Color completed = Color(0xFF6366F1);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, tealLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A4A), Color(0xFF2D5A6A)],
  );

  // Dark gradients
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF0055D4)],
  );

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color inputBorder = Color(0xFFCBD5E1);

  // Dark Border
  static const Color darkBorder = Color(0xFF3A3A3C);
  static const Color darkDivider = Color(0xFF38383A);

  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x26000000);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
}
