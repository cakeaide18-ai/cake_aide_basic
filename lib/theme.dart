import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightModeColors {
  static const lightPrimary = Color(0xFFF778A3); // Soft Pink
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFFCE4EC); // Light Pink Container
  static const lightOnPrimaryContainer = Color(0xFF880E4F);
  static const lightSecondary = Color(0xFF9E9E9E); // Neutral Gray
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightTertiary = Color(0xFFF8BBD9); // Pastel Pink
  static const lightOnTertiary = Color(0xFF4A148C);
  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF410002);
  static const lightInversePrimary = Color(0xFFF48FB1);
  static const lightShadow = Color(0xFF000000);
  static const lightSurface = Color(0xFFFAFAFA);
  static const lightOnSurface = Color(0xFF1C1C1C);
  static const lightAppBarBackground = Color(0xFFE91E63); // Pink App Bar
  static const lightBackground = Color(0xFFF5F5F5); // Light Background
  static const lightOnBackground = Color(0xFF212121);
  
  // Gradient colors for consistent theming
  static const gradientStart = Color(0xFFF778A3);
  static const gradientEnd = Color(0xFFE91E63);
  static const lightGradientStart = Color(0xFFFCE4EC);
  static const lightGradientEnd = Color(0xFFF8BBD9);
}

class DarkModeColors {
  static const darkPrimary = Color(0xFFD4BCCF);
  static const darkOnPrimary = Color(0xFF38265C);
  static const darkPrimaryContainer = Color(0xFF4F3D74);
  static const darkOnPrimaryContainer = Color(0xFFEAE0FF);
  static const darkSecondary = Color(0xFFCDC3DC);
  static const darkOnSecondary = Color(0xFF34313F);
  static const darkTertiary = Color(0xFFF0B6C5);
  static const darkOnTertiary = Color(0xFF4A2530);
  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);
  static const darkInversePrimary = Color(0xFF684F8E);
  static const darkShadow = Color(0xFF000000);
  static const darkSurface = Color(0xFF121212);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkAppBarBackground = Color(0xFF4F3D74);
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

// Gradient decorations for consistent theming across the app
class GradientDecorations {
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [
      LightModeColors.gradientStart,
      LightModeColors.gradientEnd,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get lightGradient => const LinearGradient(
    colors: [
      LightModeColors.lightGradientStart,
      LightModeColors.lightGradientEnd,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient primarySubtleGradient(BuildContext context) => LinearGradient(
    colors: [
      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient primaryBoldGradient(BuildContext context) => LinearGradient(
    colors: [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    inversePrimary: LightModeColors.lightInversePrimary,
    shadow: LightModeColors.lightShadow,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
  ),
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: LightModeColors.lightAppBarBackground,
    foregroundColor: LightModeColors.lightOnPrimary,
    elevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: LightModeColors.lightSurface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: LightModeColors.lightOnSurface,
    unselectedLabelColor: Color(0x99212121),
    indicatorColor: LightModeColors.lightPrimary,
    dividerColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: LightModeColors.lightSurface,
    selectedItemColor: LightModeColors.lightPrimary,
    unselectedItemColor: Color(0x99212121),
    type: BottomNavigationBarType.fixed,
    elevation: 12,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LightModeColors.lightPrimary,
      foregroundColor: LightModeColors.lightOnPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LightModeColors.lightOnSurface.withValues(alpha: 0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: LightModeColors.lightPrimary),
    ),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.bebasNeue(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal, // Bebas Neue is naturally bold
    ),
    displayMedium: GoogleFonts.bebasNeue(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.bebasNeue(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.normal,
    ),
    headlineLarge: GoogleFonts.bebasNeue(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal, // Headlines use Bebas Neue for impact
    ),
    headlineMedium: GoogleFonts.bebasNeue(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.normal,
    ),
    headlineSmall: GoogleFonts.bebasNeue(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.normal,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600, // Semi-bold for titles
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500, // Medium for titles
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500, // Medium for small titles
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500, // Medium for labels
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500, // Medium for labels
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w400, // Regular for small labels
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400, // Regular for body text
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400, // Regular for body text
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400, // Regular for small body text
    ),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    inversePrimary: DarkModeColors.darkInversePrimary,
    shadow: DarkModeColors.darkShadow,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
  ),
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: DarkModeColors.darkAppBarBackground,
    foregroundColor: DarkModeColors.darkOnPrimaryContainer,
    elevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: DarkModeColors.darkSurface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: DarkModeColors.darkOnSurface,
    unselectedLabelColor: DarkModeColors.darkOnSurface.withValues(alpha: 0.6),
    indicatorColor: DarkModeColors.darkPrimary,
    dividerColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: DarkModeColors.darkSurface,
    selectedItemColor: DarkModeColors.darkPrimary,
    unselectedItemColor: DarkModeColors.darkOnSurface.withValues(alpha: 0.6),
    type: BottomNavigationBarType.fixed,
    elevation: 12,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.bebasNeue(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.normal, // Bebas Neue is naturally bold
    ),
    displayMedium: GoogleFonts.bebasNeue(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.normal,
    ),
    displaySmall: GoogleFonts.bebasNeue(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.normal,
    ),
    headlineLarge: GoogleFonts.bebasNeue(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.normal, // Headlines use Bebas Neue for impact
    ),
    headlineMedium: GoogleFonts.bebasNeue(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.normal,
    ),
    headlineSmall: GoogleFonts.bebasNeue(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.normal,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600, // Semi-bold for titles
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500, // Medium for titles
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500, // Medium for small titles
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500, // Medium for labels
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500, // Medium for labels
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w400, // Regular for small labels
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400, // Regular for body text
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400, // Regular for body text
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400, // Regular for small body text
    ),
  ),
);