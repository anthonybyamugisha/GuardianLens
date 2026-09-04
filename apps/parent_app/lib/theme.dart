import 'package:flutter/material.dart';

class AppColors {
  static const primaryBlue = Color(0xFF0757C9);
  static const primaryBlueLight = Color(0xFF378ADD);
  static const primaryBlueDark = Color(0xFF0649AA);
  static const successGreen = Color(0xFF1D9E75);
  static const warningOrange = Color(0xFFC15E14);
  static const dangerRed = Color(0xFFD93030);
  static const dangerRedLight = Color(0xFFE24B4A);
  static const amber = Color(0xFFC47A0B);
  static const pageBackground = Color(0xFFF4F2FA);
  static const cardBackground = Color(0xFFFBFAFF);
  static const surfaceFill = Color(0xFFF0EEF7);
  static const surfaceFillHover = Color(0xFFE8E5F2);
  static const blueSurface = Color(0xFFEEF5FA);
  static const blueSurfaceBorder = Color(0xFFDCE6ED);
  static const softGreenSurface = Color(0xFFE7F5EE);
  static const redSurface = Color(0xFFFCEBEB);
  static const redCard = Color(0xFFFFF8F8);
  static const redCardBorder = Color(0xFFF1D8D8);
  static const textPrimary = Color(0xFF252523);
  static const textSecondary = Color(0xFF777483);
  static const textFaint = Color(0xFF8D8A99);
  static const textMuted = Color(0xFF888780);
  static const textPlaceholder = Color(0xFFC2BFCD);
  static const borderSubtle = Color(0xFFECEAF2);
  static const borderInput = Color(0xFFDDD9E8);
  static const toggleOff = Color(0xFFD8D5CC);
  static const chipGrey = Color(0xFFE6E6EE);
  static const chipTextGrey = Color(0xFF252523);
  static const purpleAccent = Color(0xFF7A56B5);
  static const paleGreenSurface = Color(0xFFD9F4EE);
  static const paleBlueSurface = Color(0xFFE8F2FC);
  static const paleRedSurface = Color(0xFFFCE3E3);
  static const paleOrangeSurface = Color(0xFFFCE8D8);
  static const paleGreenBadge = Color(0xFFD7F2E5);
  static const paleAmberSurface = Color(0xFFF2F1F9);
  static const inputBackground = Color(0xFFFCFBFF);
  static const buttonGrey = Color(0xFFECEAF5);
  static const buttonGreyHover = Color(0xFFE1DFEF);
  static const blueChipBorder = Color(0xFFC8DDF0);
  static const blueDisabled = Color(0xFFB8CBE5);
  static const stepBlue = Color(0xFFE8F2FC);
  static const chevronGrey = Color(0xFFB8B4C5);
  static const softAmberBg = Color(0xFFFCE8D8);

  static const calloutBorder = Color(0xFFE7E3DA);
  static const textLightBlue = Color(0xFF575563);
}

class AppShadows {
  static const brandMark = BoxShadow(
    color: Color(0x3B378ADD),
    blurRadius: 20,
    offset: Offset(0, 10),
  );
  static const phoneFrame = BoxShadow(
    color: Color(0x1A373264),
    blurRadius: 45,
    offset: Offset(0, 18),
  );
  static const card = BoxShadow(
    color: Color(0x0F373264),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
  static const form = BoxShadow(
    color: Color(0x0F373264),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
  static const primaryButton = BoxShadow(
    color: Color(0x330757C9),
    blurRadius: 18,
    offset: Offset(0, 8),
  );
  static const logoGlow = BoxShadow(
    color: Color(0x47378ADD),
    blurRadius: 24,
    offset: Offset(0, 10),
  );
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.pageBackground,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.04,
          fontSize: 27,
        ),
        titleLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.035,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        bodySmall: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}