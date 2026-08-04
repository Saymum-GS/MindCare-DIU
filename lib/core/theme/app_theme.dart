import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── PUBLIC GETTERS ────────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildLightTheme();
  static ThemeData get darkTheme => _buildDarkTheme();

  // Keep for backward compat with app.dart that calls AppTheme.theme
  static ThemeData get theme => _buildLightTheme();

  // ── LIGHT THEME (HIG) ─────────────────────────────────────────────────
  static ThemeData _buildLightTheme() {
    final cs = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.systemBlueLight,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.blue100,
      onPrimaryContainer: AppColors.systemBlueLight,
      secondary: AppColors.systemGreenLight,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.sage100,
      onSecondaryContainer: AppColors.systemGreenLight,
      tertiary: AppColors.systemOrangeLight,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.amber100,
      onTertiaryContainer: AppColors.systemOrangeLight,
      error: AppColors.systemRedLight,
      onError: AppColors.white,
      errorContainer: AppColors.red100,
      onErrorContainer: AppColors.systemRedLight,
      surface: AppColors.white,
      onSurface: AppColors.gray900,
      surfaceContainerHighest: AppColors.gray100,
      surfaceContainerHigh: AppColors.gray50,
      outline: AppColors.gray300,
      outlineVariant: AppColors.gray200,
      shadow: AppColors.gray900,
      scrim: AppColors.gray900,
      inverseSurface: AppColors.gray900,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.systemBlueLight,
    );

    return _themeFromScheme(cs, Brightness.light);
  }

  // ── DARK THEME (HIG) ──────────────────────────────────────────────────
  static ThemeData _buildDarkTheme() {
    final cs = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.systemBlueDark,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.darkSurface3,
      onPrimaryContainer: AppColors.systemBlueDark,
      secondary: AppColors.systemGreenDark,
      onSecondary: AppColors.white,
      secondaryContainer: const Color(0xFF1B3B2B),
      onSecondaryContainer: AppColors.systemGreenDark,
      tertiary: AppColors.systemOrangeDark,
      onTertiary: AppColors.white,
      tertiaryContainer: const Color(0xFF3D2A12),
      onTertiaryContainer: AppColors.systemOrangeDark,
      error: AppColors.systemRedDark,
      onError: AppColors.white,
      errorContainer: const Color(0xFF3B1A1A),
      onErrorContainer: AppColors.systemRedDark,
      surface: AppColors.darkBg, // True Black
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurface3,
      surfaceContainerHigh: AppColors.darkSurface2,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderSoft,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.white,
      onInverseSurface: AppColors.gray900,
      inversePrimary: AppColors.systemBlueDark,
    );

    return _themeFromScheme(cs, Brightness.dark);
  }

  // ── SHARED THEME BUILDER ──────────────────────────────────────────────
  static ThemeData _themeFromScheme(ColorScheme cs, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = _buildTextTheme(isDark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      textTheme: textTheme,

      // ── Page Transitions (Native Feel) ──
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ── AppBar (Native iOS Style) ──
      appBarTheme: AppBarTheme(
        centerTitle: true, // iOS standard
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        foregroundColor: isDark ? AppColors.darkText : AppColors.gray900,
        elevation: 0,
        scrolledUnderElevation: 0, // Disable material scroll tint
        shadowColor: isDark ? AppColors.darkBorder : AppColors.gray200,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.light,
              ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600, // iOS Navigation title weight
          color: isDark ? AppColors.darkText : AppColors.gray900,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
          size: 24,
        ),
      ),

      // ── Cards (Flat, border-radius 16, no shadows) ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? const BorderSide(color: AppColors.darkBorderSoft, width: 1)
              : const BorderSide(color: AppColors.gray300, width: 0.5),
        ),
      ),

      // ── Filled Button (Pill or 14px radius) ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor:
              isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
          foregroundColor: AppColors.white,
          disabledBackgroundColor:
              isDark ? AppColors.darkSurface3 : AppColors.gray200,
          disabledForegroundColor:
              isDark ? AppColors.darkTextTert : AppColors.gray500,
          minimumSize: const Size(0, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.4),
          elevation: 0,
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
          side: BorderSide(
              color: isDark
                  ? AppColors.systemBlueDark
                  : AppColors.systemBlueLight),
          minimumSize: const Size(0, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.4),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
          textStyle: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: -0.4),
          minimumSize: const Size(0, 44),
        ),
      ),

      // ── Input Decoration (iOS native feel) ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface3 : AppColors.gray100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color:
                isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.riskRedFg),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.riskRedFg, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: isDark ? AppColors.darkTextSub : AppColors.gray600,
          fontSize: 17,
        ),
        hintStyle: GoogleFonts.inter(
          color: isDark ? AppColors.darkTextTert : AppColors.gray500,
          fontSize: 17,
        ),
        errorStyle: GoogleFonts.inter(
          color: AppColors.riskRedFg,
          fontSize: 13,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Bottom Navigation ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        indicatorColor: Colors.transparent, // Disable material pill indicator
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? (isDark
                    ? AppColors.systemBlueDark
                    : AppColors.systemBlueLight)
                : (isDark ? AppColors.gray600 : AppColors.gray400),
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? (isDark
                    ? AppColors.systemBlueDark
                    : AppColors.systemBlueLight)
                : (isDark ? AppColors.gray600 : AppColors.gray400),
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        height: 66,
      ),

      // ── Chips ──
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.gray200,
        selectedColor: isDark
            ? AppColors.systemBlueDark.withValues(alpha: 0.2)
            : AppColors.blue100,
        labelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        checkmarkColor:
            isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkBorderSoft : AppColors.gray200,
        thickness: 0.5,
        space: 0,
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: isDark ? AppColors.darkText : AppColors.gray900,
        ),
      ),

      // ── SnackBar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurface3 : AppColors.gray900,
        contentTextStyle:
            GoogleFonts.inter(color: AppColors.white, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),

      // ── Progress Indicator ──
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
        circularTrackColor: isDark ? AppColors.darkBorder : AppColors.gray200,
      ),

      // ── Tab Bar ──
      tabBarTheme: TabBarThemeData(
        labelColor:
            isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
        unselectedLabelColor:
            isDark ? AppColors.darkTextTert : AppColors.gray500,
        indicatorColor:
            isDark ? AppColors.systemBlueDark : AppColors.systemBlueLight,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.4),
        unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.4),
        dividerColor: isDark ? AppColors.darkBorderSoft : AppColors.gray300,
      ),

      // ── List Tile ──
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: isDark ? AppColors.darkTextSub : AppColors.gray500,
        textColor: isDark ? AppColors.darkText : AppColors.gray900,
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 15,
          color: isDark ? AppColors.darkTextSub : AppColors.gray500,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.darkText : AppColors.gray900,
          letterSpacing: -0.4,
        ),
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 12,
      ),

      // ── Bottom Sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: isDark ? AppColors.gray600 : AppColors.gray300,
      ),
    );
  }

  // ── TYPOGRAPHY SYSTEM (Inter / SF Pro Equivalent) ───────────────────────
  static TextTheme _buildTextTheme(bool isDark) {
    final textColor = isDark ? AppColors.darkText : AppColors.gray900;
    final subColor = isDark ? AppColors.darkTextSub : AppColors.gray500;

    return TextTheme(
      // Display
      displayLarge: GoogleFonts.inter(
          fontSize: 57,
          color: textColor,
          height: 1.12,
          letterSpacing: -0.5,
          fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.inter(
          fontSize: 45,
          color: textColor,
          height: 1.16,
          letterSpacing: -0.5,
          fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.inter(
          fontSize: 36,
          color: textColor,
          height: 1.22,
          letterSpacing: -0.4,
          fontWeight: FontWeight.bold),

      // Headlines
      headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          color: textColor,
          height: 1.25,
          letterSpacing: -0.4,
          fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          color: textColor,
          height: 1.29,
          letterSpacing: -0.4,
          fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          color: textColor,
          height: 1.33,
          letterSpacing: -0.4,
          fontWeight: FontWeight.w600),

      // Titles
      titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.27,
          letterSpacing: -0.4),
      titleMedium: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.3,
          letterSpacing: -0.4),
      titleSmall: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.3,
          letterSpacing: -0.4),

      // Body
      bodyLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.5,
          letterSpacing: -0.4),
      bodyMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.5,
          letterSpacing: -0.2),
      bodySmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: subColor,
          height: 1.4),

      // Labels
      labelLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 1.4,
          letterSpacing: -0.2),
      labelMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: subColor,
          height: 1.3),
      labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: subColor,
          height: 1.3),
    );
  }
}
