import 'package:flutter/material.dart';

class AppColors {
  // Vibrant accents based on Stitch designs
  static const Color primary = Color(0xFF1392EC);
  static const Color primaryLight = Color(0xFF5AB6FF);
  static const Color primaryDark = Color(0xFF0B6BB0);

  // Secondary/Accent Colors - Neon Blue/Cyan/Purple
  static const Color accent = Color(0xFF25AFF4);
  static const Color accentLight = Color(0xFF6ED4FF);
  static const Color accentDark = Color(0xFF008CC9);

  static const Color teal = Color(0xFF00D4FF); // Bright Cyan
  static const Color tealLight = Color(0xFF70E8FF);
  static const Color tealDark = Color(0xFF00A2C2);
  
  static const Color purple = Color(0xFF7C3AED); // Vibrant Purple
  static const Color neonOrange = Color(0xFFFF6B35); // Bright Orange

  // Background Colors - Sleek Professional Light Theme
  static const Color scaffoldBackground = Color(0xFFF8F9FA); // Very light grey
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);

  // Background Colors - Dark (AMOLED & Sleek dark)
  static const Color darkBackground = Color(0xFF0F1115); // Deep dark blue/grey
  static const Color darkSurface = Color(0xFF171A21); // Slightly elevated
  static const Color darkCardBackground = Color(0xFF1E222A); // Elevated card
  static const Color darkScaffoldBackground = Color(0xFF0A0C10); // Very deep background

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1C1E); // Crisp dark text
  static const Color textSecondary = Color(0xFF8E8E93); // Apple grey text
  static const Color textLight = Color(0xFFA6A6A6);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1C1C1E);

  // Text Colors - Dark Mode
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1); 
  static const Color darkTextMuted = Color(0xFF64748B);

  // Dark Mode Accents (New Premium Look)
  static const Color darkPrimary = Color(0xFF1973F0); 
  static const Color darkAccent = Color(0xFF25AFF4); 
  static const Color darkError = Color(0xFFFF453A);

  // Status Colors (Apple-like semantic colors)
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFE5F8E9);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningLight = Color(0xFFFFF4E5);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFDE9E8);
  static const Color info = Color(0xFF0D7FF2);
  static const Color infoLight = Color(0xFFE7F2FD);

  // Badge Colors
  static const Color badgeNew = primary;
  static const Color badgeUsed = warning;
  static const Color badgePromoted = purple;
  static const Color badgeFeatured = info;

  // Booking Status Colors
  static const Color pending = warning;
  static const Color confirmed = success;
  static const Color cancelled = error;
  static const Color completed = primary;

  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1392EC), Color(0xFF25AFF4)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, teal],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, primaryLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1392EC), Color(0xFF0B6BB0)],
  );
  
  static const LinearGradient vibrantGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const LinearGradient fireGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, neonOrange],
  );

  // Dark gradients
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkCardBackground, darkSurface],
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, purple],
  );

  // Borders & Dividers
  static const Color border = Color(0xFFE5E5EA); // Fine subtle border
  static const Color divider = Color(0xFFF2F2F7);
  static const Color inputBorder = Color(0xFFD1D1D6);

  // Dark Border
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF1E293B);

  // Shadows
  static const Color shadow = Color(0x0A000000); // 4% black
  static const Color shadowLight = Color(0x05000000); // 2% 
  static const Color shadowMedium = Color(0x14000000); // 8%

  // Overlays
  static const Color overlay = Color(0x40000000);
  static const Color overlayLight = Color(0x26000000);
}
