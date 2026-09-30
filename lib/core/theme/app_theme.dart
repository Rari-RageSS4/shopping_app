import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design system for the Shopping App.
///
/// HOW TO USE:
///   - Access colours  → AppTheme.primary, AppTheme.accent, etc.
///   - Access text     → AppTheme.textTheme (or Theme.of(context).textTheme)
///   - Apply theme     → MaterialApp(theme: AppTheme.lightTheme)
///
/// NEVER hard-code colours or text styles in individual widgets.
/// Always pull values from here so the entire app stays visually consistent.
class AppTheme {
  AppTheme._();

  // ── Colour Palette ───────────────────────────────────────────────────────────
  // Deep navy + amber/gold accent — premium, distinctive, not a generic template.

  /// Primary brand colour — deep navy.
  static const Color primary = Color(0xFF1A1F3A);

  /// Amber/gold accent — buttons, highlights, selected states.
  static const Color accent = Color(0xFFF5A623);

  /// Slightly lighter navy for secondary actions and secondary text backgrounds.
  static const Color primaryLight = Color(0xFF2D3561);

  /// App background — a very light blue-tinted white. Feels cleaner than pure white.
  static const Color background = Color(0xFFF8F9FF);

  /// Surface colour for cards and sheet backgrounds.
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle border / divider colour.
  static const Color border = Color(0xFFE8EAF6);

  /// Error red.
  static const Color error = Color(0xFFE53935);

  /// Success green (stock in stock, etc.).
  static const Color success = Color(0xFF43A047);

  // ── Text Colours ─────────────────────────────────────────────────────────────

  /// Main body text — same as primary so headings and body share one colour.
  static const Color textPrimary = Color(0xFF1A1F3A);

  /// Secondary text — muted labels, subtitles, hints.
  static const Color textSecondary = Color(0xFF7B8BB2);

  /// Light text for use on dark (primary) backgrounds.
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Text on accent (amber) backgrounds — use dark for contrast.
  static const Color textOnAccent = Color(0xFF1A1F3A);

  // ── Border Radius ─────────────────────────────────────────────────────────────

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0; // pill shape

  // ── Elevation / Shadow ────────────────────────────────────────────────────────

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  


    static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // ── Product card helpers ──────────────────────────────────────────────────

  /// Scrim behind badges that sit on top of product photos.
  static const Color scrim = Color(0x8C000000);

  /// Height of compact buttons (e.g. Add to Cart on product cards).
  static const double buttonHeightCompact = 36.0;

  /// Text style for small pill badges (discount, rating).
  static TextStyle get badgeText => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: textOnDark,
      );

  // ── Spacing ───────────────────────────────────────────────────────────────────

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Animation Durations ───────────────────────────────────────────────────────

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // ── Typography (Google Fonts) ─────────────────────────────────────────────────
  // Poppins for headings — geometric and modern.
  // Inter for body — highly legible at small sizes.

  static TextTheme get textTheme => TextTheme(
        // ── Display ──
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),

        // ── Headlines ──
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),

        // ── Titles ──
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),

        // ── Body ──
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),

        // ── Labels ──
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      );

  // ── Full Material Theme ───────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: textOnDark,
        secondary: accent,
        onSecondary: textOnAccent,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: textOnDark,
      ),
      scaffoldBackgroundColor: background,
      textTheme: textTheme,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: textOnDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textOnDark,
        ),
        iconTheme: const IconThemeData(color: textOnDark),
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textOnAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),

      // ── Card ──
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor: primary,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textOnDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingSm,
          vertical: spacingXs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: const BorderSide(color: border),
        ),
      ),

      // ── Bottom Navigation Bar ──
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Divider ──
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textOnDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }
}
