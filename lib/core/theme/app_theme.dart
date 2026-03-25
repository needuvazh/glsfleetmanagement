import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  // Fresh modern palette - Deep Navy & Emerald with Gold accents
  static const _primaryNavy = Color(0xFF0F1729);
  static const _accentEmerald = Color(0xFF10B981);
  static const _accentGold = Color(0xFFD4AF37);
  static const _surfaceLight = Color(0xFFFAFBFC);
  static const _surfaceDark = Color(0xFF1A1F2E);

  static ThemeData get light {
    final colors = ColorScheme(
      brightness: Brightness.light,
      primary: _accentEmerald,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD1FAE5),
      onPrimaryContainer: const Color(0xFF064E3B),
      secondary: _accentGold,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFEF3C7),
      onSecondaryContainer: const Color(0xFF78350F),
      tertiary: const Color(0xFF6366F1),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFE0E7FF),
      onTertiaryContainer: const Color(0xFF3730A3),
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF991B1B),
      surface: Colors.white,
      onSurface: _primaryNavy,
      surfaceContainerHighest: const Color(0xFFF1F5F9),
      onSurfaceVariant: const Color(0xFF64748B),
      outline: const Color(0xFFCBD5E1),
      outlineVariant: const Color(0xFFE2E8F0),
      shadow: Colors.black.withOpacity(0.08),
      scrim: Colors.black.withOpacity(0.4),
      inverseSurface: _primaryNavy,
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF34D399),
    );

    return _buildTheme(colors);
  }

  static ThemeData get dark {
    final colors = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF34D399),
      onPrimary: const Color(0xFF064E3B),
      primaryContainer: const Color(0xFF065F46),
      onPrimaryContainer: const Color(0xFFD1FAE5),
      secondary: const Color(0xFFFCD34D),
      onSecondary: const Color(0xFF78350F),
      secondaryContainer: const Color(0xFF92400E),
      onSecondaryContainer: const Color(0xFFFEF3C7),
      tertiary: const Color(0xFFA5B4FC),
      onTertiary: const Color(0xFF3730A3),
      tertiaryContainer: const Color(0xFF4338CA),
      onTertiaryContainer: const Color(0xFFE0E7FF),
      error: const Color(0xFFFCA5A5),
      onError: const Color(0xFF991B1B),
      errorContainer: const Color(0xFFB91C1C),
      onErrorContainer: const Color(0xFFFEE2E2),
      surface: _surfaceDark,
      onSurface: const Color(0xFFF8FAFC),
      surfaceContainerHighest: const Color(0xFF334155),
      onSurfaceVariant: const Color(0xFF94A3B8),
      outline: const Color(0xFF475569),
      outlineVariant: const Color(0xFF334155),
      shadow: Colors.black.withOpacity(0.3),
      scrim: Colors.black.withOpacity(0.6),
      inverseSurface: const Color(0xFFF8FAFC),
      onInverseSurface: _primaryNavy,
      inversePrimary: _accentEmerald,
    );

    return _buildTheme(colors);
  }

  static ThemeData _buildTheme(ColorScheme colors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.brightness == Brightness.light 
          ? _surfaceLight 
          : const Color(0xFF0F1419),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: colors.onSurface, letterSpacing: -1.5),
        displayMedium: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: colors.onSurface, letterSpacing: -1),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: colors.onSurface, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: colors.onSurface, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: colors.onSurface, letterSpacing: -0.3),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colors.onSurface),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: colors.onSurface, letterSpacing: -0.2),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.onSurface),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.onSurface),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colors.onSurface, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: colors.onSurface, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: colors.onSurface, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface, letterSpacing: 0.5),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.onSurface),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.onSurface),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        shadowColor: colors.shadow,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.w700, 
          color: colors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outlineVariant, width: 1),
        ),
        shadowColor: colors.shadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.brightness == Brightness.light 
            ? colors.surfaceContainerHighest.withOpacity(0.5)
            : colors.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        labelStyle: TextStyle(color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.6)),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colors.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: colors.outline, width: 1.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.primaryContainer,
        labelStyle: TextStyle(
          color: colors.onPrimaryContainer, 
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(colors.surfaceContainerHighest.withOpacity(0.5)),
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.w700, 
          color: colors.onSurface,
        ),
        dataTextStyle: TextStyle(
          color: colors.onSurface,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(
          color: colors.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
