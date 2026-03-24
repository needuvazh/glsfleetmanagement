import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const _seedColor = Color(0xFF0E7490); // A deep teal for primary branding

  static ThemeData get light {
    final colors = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      // Define a more comprehensive color scheme
      primary: const Color(0xFF0E7490),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFB2EBF2),
      onPrimaryContainer: const Color(0xFF004D40),
      secondary: const Color(0xFFFFA726), // Safety Orange for accents
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFCC80),
      onSecondaryContainer: const Color(0xFFE65100),
      tertiary: const Color(0xFF66BB6A), // Safety Green for success/compliance
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFA5D6A7),
      onTertiaryContainer: const Color(0xFF1B5E20),
      error: const Color(0xFFEF5350), // Red for errors/alerts
      onError: Colors.white,
      errorContainer: const Color(0xFFFFCDD2),
      onErrorContainer: const Color(0xFFB71C1C),
      background: const Color(0xFFF8F9FA),
      onBackground: const Color(0xFF212121),
      surface: Colors.white,
      onSurface: const Color(0xFF212121),
      surfaceVariant: const Color(0xFFE0E0E0),
      onSurfaceVariant: const Color(0xFF424242),
      outline: const Color(0xFFBDBDBD),
      shadow: Colors.black.withOpacity(0.1),
      inverseSurface: const Color(0xFF303030),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF80DEEA),
      surfaceTint: _seedColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.background,
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: colors.onBackground),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: colors.onBackground),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: colors.onBackground),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: colors.onBackground),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: colors.onBackground),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: colors.onBackground),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.onBackground, letterSpacing: -0.2),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onBackground, letterSpacing: -0.1),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.onBackground),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colors.onBackground, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: colors.onBackground, height: 1.35),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: colors.onBackground),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.onBackground),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onBackground),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onBackground),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 1,
        shadowColor: colors.shadow,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: colors.shadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      // Add more component themes as needed
      chipTheme: ChipThemeData(
        backgroundColor: colors.primaryContainer,
        labelStyle: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(colors.surfaceVariant.withOpacity(0.5)),
        headingTextStyle: TextStyle(fontWeight: FontWeight.w700, color: colors.onSurface),
        dataTextStyle: TextStyle(color: colors.onSurface),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final colors = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF80DEEA),
      onPrimary: const Color(0xFF004D40),
      primaryContainer: const Color(0xFF004D40),
      onPrimaryContainer: const Color(0xFFB2EBF2),
      secondary: const Color(0xFFFFCC80),
      onSecondary: const Color(0xFFE65100),
      secondaryContainer: const Color(0xFFE65100),
      onSecondaryContainer: const Color(0xFFFFCC80),
      tertiary: const Color(0xFFA5D6A7),
      onTertiary: const Color(0xFF1B5E20),
      tertiaryContainer: const Color(0xFF1B5E20),
      onTertiaryContainer: const Color(0xFFA5D6A7),
      error: const Color(0xFFFF8A80),
      onError: const Color(0xFFB71C1C),
      errorContainer: const Color(0xFFB71C1C),
      onErrorContainer: const Color(0xFFFFCDD2),
      background: const Color(0xFF121212),
      onBackground: Colors.white,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      surfaceVariant: const Color(0xFF424242),
      onSurfaceVariant: const Color(0xFFBDBDBD),
      outline: const Color(0xFF616161),
      shadow: Colors.black.withOpacity(0.3),
      inverseSurface: const Color(0xFFE0E0E0),
      onInverseSurface: const Color(0xFF212121),
      inversePrimary: const Color(0xFF0E7490),
      surfaceTint: _seedColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.background,
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: colors.onBackground),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: colors.onBackground),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: colors.onBackground),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: colors.onBackground),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: colors.onBackground),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: colors.onBackground),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.onBackground, letterSpacing: -0.2),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onBackground, letterSpacing: -0.1),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.onBackground),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colors.onBackground, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: colors.onBackground, height: 1.35),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: colors.onBackground),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.onBackground),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onBackground),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onBackground),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 1,
        shadowColor: colors.shadow,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: colors.shadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.primaryContainer,
        labelStyle: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(colors.surfaceVariant.withOpacity(0.5)),
        headingTextStyle: TextStyle(fontWeight: FontWeight.w700, color: colors.onSurface),
        dataTextStyle: TextStyle(color: colors.onSurface),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
