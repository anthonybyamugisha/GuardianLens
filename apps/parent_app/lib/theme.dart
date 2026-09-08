import 'package:flutter/material.dart';

/// Brand colors that stay constant across light and dark themes.
class AppColors {
  static const primaryBlue = Color(0xFF0757C9);
  static const primaryBlueLight = Color(0xFF378ADD);
  static const primaryBlueDark = Color(0xFF0649AA);
  static const successGreen = Color(0xFF1D9E75);
  static const warningOrange = Color(0xFFC15E14);
  static const dangerRed = Color(0xFFD93030);
  static const dangerRedLight = Color(0xFFE24B4A);
  static const amber = Color(0xFFC47A0B);
  static const purpleAccent = Color(0xFF7A56B5);
}

/// Theme-dependent palette. Access it via `context.colors`.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.pageBackground,
    required this.cardBackground,
    required this.surfaceFill,
    required this.surfaceFillHover,
    required this.blueSurface,
    required this.blueSurfaceBorder,
    required this.softGreenSurface,
    required this.redSurface,
    required this.redCard,
    required this.redCardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textFaint,
    required this.textMuted,
    required this.textPlaceholder,
    required this.borderSubtle,
    required this.borderInput,
    required this.toggleOff,
    required this.chipGrey,
    required this.chipTextGrey,
    required this.paleGreenSurface,
    required this.paleBlueSurface,
    required this.paleRedSurface,
    required this.paleOrangeSurface,
    required this.paleGreenBadge,
    required this.paleAmberSurface,
    required this.inputBackground,
    required this.buttonGrey,
    required this.buttonGreyHover,
    required this.blueChipBorder,
    required this.blueDisabled,
    required this.stepBlue,
    required this.chevronGrey,
    required this.softAmberBg,
    required this.calloutBorder,
    required this.textLightBlue,
  });

  final Color pageBackground;
  final Color cardBackground;
  final Color surfaceFill;
  final Color surfaceFillHover;
  final Color blueSurface;
  final Color blueSurfaceBorder;
  final Color softGreenSurface;
  final Color redSurface;
  final Color redCard;
  final Color redCardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textFaint;
  final Color textMuted;
  final Color textPlaceholder;
  final Color borderSubtle;
  final Color borderInput;
  final Color toggleOff;
  final Color chipGrey;
  final Color chipTextGrey;
  final Color paleGreenSurface;
  final Color paleBlueSurface;
  final Color paleRedSurface;
  final Color paleOrangeSurface;
  final Color paleGreenBadge;
  final Color paleAmberSurface;
  final Color inputBackground;
  final Color buttonGrey;
  final Color buttonGreyHover;
  final Color blueChipBorder;
  final Color blueDisabled;
  final Color stepBlue;
  final Color chevronGrey;
  final Color softAmberBg;
  final Color calloutBorder;
  final Color textLightBlue;

  static const light = AppPalette(
    pageBackground: Color(0xFFF4F2FA),
    cardBackground: Color(0xFFFBFAFF),
    surfaceFill: Color(0xFFF0EEF7),
    surfaceFillHover: Color(0xFFE8E5F2),
    blueSurface: Color(0xFFEEF5FA),
    blueSurfaceBorder: Color(0xFFDCE6ED),
    softGreenSurface: Color(0xFFE7F5EE),
    redSurface: Color(0xFFFCEBEB),
    redCard: Color(0xFFFFF8F8),
    redCardBorder: Color(0xFFF1D8D8),
    textPrimary: Color(0xFF252523),
    textSecondary: Color(0xFF777483),
    textFaint: Color(0xFF8D8A99),
    textMuted: Color(0xFF888780),
    textPlaceholder: Color(0xFFC2BFCD),
    borderSubtle: Color(0xFFECEAF2),
    borderInput: Color(0xFFDDD9E8),
    toggleOff: Color(0xFFD8D5CC),
    chipGrey: Color(0xFFE6E6EE),
    chipTextGrey: Color(0xFF252523),
    paleGreenSurface: Color(0xFFD9F4EE),
    paleBlueSurface: Color(0xFFE8F2FC),
    paleRedSurface: Color(0xFFFCE3E3),
    paleOrangeSurface: Color(0xFFFCE8D8),
    paleGreenBadge: Color(0xFFD7F2E5),
    paleAmberSurface: Color(0xFFF2F1F9),
    inputBackground: Color(0xFFFCFBFF),
    buttonGrey: Color(0xFFECEAF5),
    buttonGreyHover: Color(0xFFE1DFEF),
    blueChipBorder: Color(0xFFC8DDF0),
    blueDisabled: Color(0xFFB8CBE5),
    stepBlue: Color(0xFFE8F2FC),
    chevronGrey: Color(0xFFB8B4C5),
    softAmberBg: Color(0xFFFCE8D8),
    calloutBorder: Color(0xFFE7E3DA),
    textLightBlue: Color(0xFF575563),
  );

  static const dark = AppPalette(
    pageBackground: Color(0xFF121318),
    cardBackground: Color(0xFF1B1C24),
    surfaceFill: Color(0xFF262833),
    surfaceFillHover: Color(0xFF2E3140),
    blueSurface: Color(0xFF16243A),
    blueSurfaceBorder: Color(0xFF22334A),
    softGreenSurface: Color(0xFF163129),
    redSurface: Color(0xFF3A1C1C),
    redCard: Color(0xFF2A1B1D),
    redCardBorder: Color(0xFF4A2626),
    textPrimary: Color(0xFFECEBF4),
    textSecondary: Color(0xFFA7A4B8),
    textFaint: Color(0xFF8A879C),
    textMuted: Color(0xFF9A988F),
    textPlaceholder: Color(0xFF5F5C70),
    borderSubtle: Color(0xFF2C2E3A),
    borderInput: Color(0xFF3A3D4D),
    toggleOff: Color(0xFF3E4149),
    chipGrey: Color(0xFF2C2E38),
    chipTextGrey: Color(0xFFE4E3EC),
    paleGreenSurface: Color(0xFF1A352E),
    paleBlueSurface: Color(0xFF1D2A3F),
    paleRedSurface: Color(0xFF3A2020),
    paleOrangeSurface: Color(0xFF3A2A1A),
    paleGreenBadge: Color(0xFF1C3A2C),
    paleAmberSurface: Color(0xFF2A2A38),
    inputBackground: Color(0xFF22242E),
    buttonGrey: Color(0xFF262833),
    buttonGreyHover: Color(0xFF2E3040),
    blueChipBorder: Color(0xFF2C4A6E),
    blueDisabled: Color(0xFF3A4A66),
    stepBlue: Color(0xFF1D2A3F),
    chevronGrey: Color(0xFF6A6A82),
    softAmberBg: Color(0xFF3A2A1A),
    calloutBorder: Color(0xFF3A3835),
    textLightBlue: Color(0xFFB9B6C9),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      surfaceFill: Color.lerp(surfaceFill, other.surfaceFill, t)!,
      surfaceFillHover: Color.lerp(surfaceFillHover, other.surfaceFillHover, t)!,
      blueSurface: Color.lerp(blueSurface, other.blueSurface, t)!,
      blueSurfaceBorder: Color.lerp(blueSurfaceBorder, other.blueSurfaceBorder, t)!,
      softGreenSurface: Color.lerp(softGreenSurface, other.softGreenSurface, t)!,
      redSurface: Color.lerp(redSurface, other.redSurface, t)!,
      redCard: Color.lerp(redCard, other.redCard, t)!,
      redCardBorder: Color.lerp(redCardBorder, other.redCardBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderInput: Color.lerp(borderInput, other.borderInput, t)!,
      toggleOff: Color.lerp(toggleOff, other.toggleOff, t)!,
      chipGrey: Color.lerp(chipGrey, other.chipGrey, t)!,
      chipTextGrey: Color.lerp(chipTextGrey, other.chipTextGrey, t)!,
      paleGreenSurface: Color.lerp(paleGreenSurface, other.paleGreenSurface, t)!,
      paleBlueSurface: Color.lerp(paleBlueSurface, other.paleBlueSurface, t)!,
      paleRedSurface: Color.lerp(paleRedSurface, other.paleRedSurface, t)!,
      paleOrangeSurface: Color.lerp(paleOrangeSurface, other.paleOrangeSurface, t)!,
      paleGreenBadge: Color.lerp(paleGreenBadge, other.paleGreenBadge, t)!,
      paleAmberSurface: Color.lerp(paleAmberSurface, other.paleAmberSurface, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      buttonGrey: Color.lerp(buttonGrey, other.buttonGrey, t)!,
      buttonGreyHover: Color.lerp(buttonGreyHover, other.buttonGreyHover, t)!,
      blueChipBorder: Color.lerp(blueChipBorder, other.blueChipBorder, t)!,
      blueDisabled: Color.lerp(blueDisabled, other.blueDisabled, t)!,
      stepBlue: Color.lerp(stepBlue, other.stepBlue, t)!,
      chevronGrey: Color.lerp(chevronGrey, other.chevronGrey, t)!,
      softAmberBg: Color.lerp(softAmberBg, other.softAmberBg, t)!,
      calloutBorder: Color.lerp(calloutBorder, other.calloutBorder, t)!,
      textLightBlue: Color.lerp(textLightBlue, other.textLightBlue, t)!,
    );
  }
}

extension BuildContextColors on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
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
    final palette = AppPalette.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: palette.pageBackground,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
    );
    return base.copyWith(
      extensions: [palette],
      textTheme: base.textTheme.copyWith(
        headlineMedium: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.04,
          fontSize: 27,
        ),
        titleLarge: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.035,
        ),
        bodyMedium: TextStyle(
          color: palette.textPrimary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: palette.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final palette = AppPalette.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.pageBackground,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      extensions: [palette],
      textTheme: base.textTheme.copyWith(
        headlineMedium: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.04,
          fontSize: 27,
        ),
        titleLarge: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.035,
        ),
        bodyMedium: TextStyle(
          color: palette.textPrimary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: palette.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Global controller for switching between light, dark, and system themes.
class AppThemeMode {
  AppThemeMode._();

  static final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.system);
}