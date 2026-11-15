import 'package:flutter/material.dart';
import 'package:fluxtube/core/colors.dart';

/// "Kinetic Obsidian" — the exact Material 3 color tokens exported by the
/// Stitch-generated dark and light design kits. Kept separate from
/// [AppTheme] so both the dark and light [ColorScheme]s can share the same
/// literal source values the design was authored against.
abstract class _KineticColors {
  // Dark ("Kinetic Obsidian")
  static const darkPrimary = Color(0xFFFFB3B2);
  static const darkOnPrimary = Color(0xFF680013);
  static const darkPrimaryContainer = Color(0xFFFF525E);
  static const darkOnPrimaryContainer = Color(0xFF5B0010);
  static const darkPrimaryFixed = Color(0xFFFFDAD9);
  static const darkPrimaryFixedDim = Color(0xFFFFB3B2);
  static const darkOnPrimaryFixed = Color(0xFF410008);
  static const darkOnPrimaryFixedVariant = Color(0xFF92001F);
  static const darkSecondary = Color(0xFFBDF4FF);
  static const darkOnSecondary = Color(0xFF00363D);
  static const darkSecondaryContainer = Color(0xFF00E3FD);
  static const darkOnSecondaryContainer = Color(0xFF00616D);
  static const darkSecondaryFixed = Color(0xFF9CF0FF);
  static const darkSecondaryFixedDim = Color(0xFF00DAF3);
  static const darkOnSecondaryFixed = Color(0xFF001F24);
  static const darkOnSecondaryFixedVariant = Color(0xFF004F58);
  static const darkTertiary = Color(0xFFE0B7FF);
  static const darkOnTertiary = Color(0xFF4B007D);
  static const darkTertiaryContainer = Color(0xFFBB6AFF);
  static const darkOnTertiaryContainer = Color(0xFF42006E);
  static const darkTertiaryFixed = Color(0xFFF1DAFF);
  static const darkTertiaryFixedDim = Color(0xFFE0B7FF);
  static const darkOnTertiaryFixed = Color(0xFF2D004F);
  static const darkOnTertiaryFixedVariant = Color(0xFF6B00AF);
  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);
  static const darkSurface = Color(0xFF131313);
  static const darkOnSurface = Color(0xFFE2E2E2);
  static const darkSurfaceDim = Color(0xFF131313);
  static const darkSurfaceBright = Color(0xFF393939);
  static const darkSurfaceContainerLowest = Color(0xFF0E0E0E);
  static const darkSurfaceContainerLow = Color(0xFF1B1B1B);
  static const darkSurfaceContainer = Color(0xFF1F1F1F);
  static const darkSurfaceContainerHigh = Color(0xFF2A2A2A);
  static const darkSurfaceContainerHighest = Color(0xFF353535);
  static const darkOnSurfaceVariant = Color(0xFFE8BCBB);
  static const darkOutline = Color(0xFFAE8786);
  static const darkOutlineVariant = Color(0xFF5E3F3E);
  static const darkInverseSurface = Color(0xFFE2E2E2);
  static const darkOnInverseSurface = Color(0xFF303030);
  static const darkInversePrimary = Color(0xFFBF002C);
  static const darkSurfaceTint = Color(0xFFFFB3B2);

  // Light ("Kinetic Alabaster")
  static const lightPrimary = Color(0xFFBA002B);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFE90038);
  static const lightOnPrimaryContainer = Color(0xFFFFFBFF);
  static const lightPrimaryFixed = Color(0xFFFFDAD9);
  static const lightPrimaryFixedDim = Color(0xFFFFB3B2);
  static const lightOnPrimaryFixed = Color(0xFF410008);
  static const lightOnPrimaryFixedVariant = Color(0xFF92001F);
  static const lightSecondary = Color(0xFF00696B);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFF56F5F8);
  static const lightOnSecondaryContainer = Color(0xFF006E70);
  static const lightSecondaryFixed = Color(0xFF5AF8FB);
  static const lightSecondaryFixedDim = Color(0xFF2DDBDE);
  static const lightOnSecondaryFixed = Color(0xFF002020);
  static const lightOnSecondaryFixedVariant = Color(0xFF004F51);
  static const lightTertiary = Color(0xFF006860);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightTertiaryContainer = Color(0xFF008379);
  static const lightOnTertiaryContainer = Color(0xFFF4FFFC);
  static const lightTertiaryFixed = Color(0xFF87F5E8);
  static const lightTertiaryFixedDim = Color(0xFF69D8CC);
  static const lightOnTertiaryFixed = Color(0xFF00201D);
  static const lightOnTertiaryFixedVariant = Color(0xFF00504A);
  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF93000A);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF131313);
  static const lightSurfaceDim = Color(0xFFF1F3F5);
  static const lightSurfaceBright = Color(0xFFF8F9FA);
  static const lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const lightSurfaceContainerLow = Color(0xFFF3F4F5);
  static const lightSurfaceContainer = Color(0xFFEDEEEF);
  static const lightSurfaceContainerHigh = Color(0xFFE7E8E9);
  static const lightSurfaceContainerHighest = Color(0xFFE1E3E4);
  static const lightOnSurfaceVariant = Color(0xFF495057);
  static const lightOutline = Color(0xFFDEE2E6);
  static const lightOutlineVariant = Color(0xFFE8BCBB);
  static const lightInverseSurface = Color(0xFF2E3132);
  static const lightOnInverseSurface = Color(0xFFF0F1F2);
  static const lightInversePrimary = Color(0xFFFFB3B2);
  static const lightSurfaceTint = Color(0xFFBA002B);

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    primaryFixed: darkPrimaryFixed,
    primaryFixedDim: darkPrimaryFixedDim,
    onPrimaryFixed: darkOnPrimaryFixed,
    onPrimaryFixedVariant: darkOnPrimaryFixedVariant,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    secondaryFixed: darkSecondaryFixed,
    secondaryFixedDim: darkSecondaryFixedDim,
    onSecondaryFixed: darkOnSecondaryFixed,
    onSecondaryFixedVariant: darkOnSecondaryFixedVariant,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    tertiaryFixed: darkTertiaryFixed,
    tertiaryFixedDim: darkTertiaryFixedDim,
    onTertiaryFixed: darkOnTertiaryFixed,
    onTertiaryFixedVariant: darkOnTertiaryFixedVariant,
    error: darkError,
    onError: darkOnError,
    errorContainer: darkErrorContainer,
    onErrorContainer: darkOnErrorContainer,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceDim: darkSurfaceDim,
    surfaceBright: darkSurfaceBright,
    surfaceContainerLowest: darkSurfaceContainerLowest,
    surfaceContainerLow: darkSurfaceContainerLow,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHigh: darkSurfaceContainerHigh,
    surfaceContainerHighest: darkSurfaceContainerHighest,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    inverseSurface: darkInverseSurface,
    onInverseSurface: darkOnInverseSurface,
    inversePrimary: darkInversePrimary,
    surfaceTint: darkSurfaceTint,
  );

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    primaryContainer: lightPrimaryContainer,
    onPrimaryContainer: lightOnPrimaryContainer,
    primaryFixed: lightPrimaryFixed,
    primaryFixedDim: lightPrimaryFixedDim,
    onPrimaryFixed: lightOnPrimaryFixed,
    onPrimaryFixedVariant: lightOnPrimaryFixedVariant,
    secondary: lightSecondary,
    onSecondary: lightOnSecondary,
    secondaryContainer: lightSecondaryContainer,
    onSecondaryContainer: lightOnSecondaryContainer,
    secondaryFixed: lightSecondaryFixed,
    secondaryFixedDim: lightSecondaryFixedDim,
    onSecondaryFixed: lightOnSecondaryFixed,
    onSecondaryFixedVariant: lightOnSecondaryFixedVariant,
    tertiary: lightTertiary,
    onTertiary: lightOnTertiary,
    tertiaryContainer: lightTertiaryContainer,
    onTertiaryContainer: lightOnTertiaryContainer,
    tertiaryFixed: lightTertiaryFixed,
    tertiaryFixedDim: lightTertiaryFixedDim,
    onTertiaryFixed: lightOnTertiaryFixed,
    onTertiaryFixedVariant: lightOnTertiaryFixedVariant,
    error: lightError,
    onError: lightOnError,
    errorContainer: lightErrorContainer,
    onErrorContainer: lightOnErrorContainer,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceDim: lightSurfaceDim,
    surfaceBright: lightSurfaceBright,
    surfaceContainerLowest: lightSurfaceContainerLowest,
    surfaceContainerLow: lightSurfaceContainerLow,
    surfaceContainer: lightSurfaceContainer,
    surfaceContainerHigh: lightSurfaceContainerHigh,
    surfaceContainerHighest: lightSurfaceContainerHighest,
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
    inverseSurface: lightInverseSurface,
    onInverseSurface: lightOnInverseSurface,
    inversePrimary: lightInversePrimary,
    surfaceTint: lightSurfaceTint,
  );

  /// Same brand colors as [darkScheme], but with the canvas forced to true
  /// black — "OLED Immersion" per the design system, versus the dark theme's
  /// #131313 canvas.
  static final oledScheme = darkScheme.copyWith(
    surface: const Color(0xFF000000),
    surfaceDim: const Color(0xFF000000),
    surfaceContainerLowest: const Color(0xFF000000),
  );
}

/// Text scale transcribed from the Kinetic Obsidian design system, mapped
/// onto Material 3's [TextTheme] slots. Font family/color are left to
/// [ThemeData] (`fontFamily` and `colorScheme.onSurface` respectively) so
/// this same scale applies to light, dark, and OLED without repeating itself.
TextTheme _kineticTextTheme(TextTheme base) => base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 30 / 24,
        letterSpacing: -0.015 * 24,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 28 / 20,
        letterSpacing: -0.01 * 20,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 26 / 20,
        letterSpacing: -0.01 * 20,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        letterSpacing: -0.005 * 18,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 22 / 15,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 22 / 15,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 22 / 15,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        letterSpacing: 0.01 * 13,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 14 / 11,
        letterSpacing: 0.06 * 11,
      ),
    );

abstract class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        tabBarTheme: TabBarThemeData(indicatorColor: kGreyColor),
        primaryColorLight: kWhiteColor,
        primaryColorDark: kBlackColor,
        colorScheme: _KineticColors.lightScheme,
        primaryIconTheme: const IconThemeData().copyWith(color: kBlackColor),
        scaffoldBackgroundColor: _KineticColors.lightScheme.surface,
        textTheme: _kineticTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
            backgroundColor: kWhiteColor, foregroundColor: kBlackColor),
        fontFamily: 'Montserrat',
        iconTheme: const IconThemeData().copyWith(color: kGreyColor),
      );

  static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      primaryColorLight: kWhiteColor,
      primaryColorDark: kBlackColor,
      tabBarTheme:
          TabBarThemeData(indicatorColor: kWhiteColor.withValues(alpha: 0.5)),
      primaryIconTheme: const IconThemeData().copyWith(color: kWhiteColor),
      colorScheme: _KineticColors.darkScheme,
      scaffoldBackgroundColor: _KineticColors.darkScheme.surface,
      dividerTheme: const DividerThemeData().copyWith(color: kGreyOpacityColor),
      textTheme: _kineticTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        // Match the #131313 canvas; pure black is reserved for OLED.
        backgroundColor: _KineticColors.darkScheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: kWhiteColor,
        iconTheme: const IconThemeData().copyWith(color: kWhiteColor),
        actionsIconTheme: const IconThemeData().copyWith(color: kWhiteColor),
      ),
      fontFamily: 'Montserrat',
      iconTheme: const IconThemeData()
          .copyWith(color: kWhiteColor.withValues(alpha: 0.7)),
      inputDecorationTheme: const InputDecorationTheme().copyWith(
        iconColor: kWhiteColor,
        prefixIconColor: kWhiteColor,
        suffixIconColor: kWhiteColor,
      ));

  static ThemeData get oledTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColorLight: kWhiteColor,
        primaryColorDark: const Color(0xFF000000),
        tabBarTheme: const TabBarThemeData(indicatorColor: Colors.white),
        primaryIconTheme: const IconThemeData().copyWith(color: kWhiteColor),
        colorScheme: _KineticColors.oledScheme,
        scaffoldBackgroundColor: const Color(0xFF000000),
        dividerTheme: const DividerThemeData().copyWith(color: Colors.white12),
        textTheme: _kineticTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          foregroundColor: kWhiteColor,
          elevation: 0,
          iconTheme: IconThemeData(color: kWhiteColor),
          actionsIconTheme: IconThemeData(color: kWhiteColor),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF000000),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
        ),
        fontFamily: 'Montserrat',
        iconTheme: const IconThemeData()
            .copyWith(color: kWhiteColor.withValues(alpha: 0.7)),
        inputDecorationTheme: const InputDecorationTheme().copyWith(
          iconColor: kWhiteColor,
          prefixIconColor: kWhiteColor,
          suffixIconColor: kWhiteColor,
        ),
        cardColor: const Color(0xFF0A0A0A),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF0A0A0A)),
      );

  static ThemeData dynamicTheme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        tabBarTheme: TabBarThemeData(
            indicatorColor: colorScheme.onSurface.withValues(alpha: 0.6)),
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        ),
        fontFamily: 'Montserrat',
        textTheme: _kineticTextTheme(ThemeData(
          brightness: colorScheme.brightness,
          useMaterial3: true,
        ).textTheme),
        iconTheme:
            IconThemeData(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        dividerTheme: DividerThemeData(
            color: colorScheme.onSurface.withValues(alpha: 0.12)),
      );
}
