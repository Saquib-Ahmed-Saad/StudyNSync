import 'package:flutter/material.dart';

class StudyNSyncColors {
  static const Color midnightBlue = Color(0xFF0F1A2C);
  static const Color deepNavy = Color(0xFF152238);
  static const Color charcoal = Color(0xFF23262F);
  static const Color parchment = Color(0xFFE8DDC6);
  static const Color mutedGold = Color(0xFFB59A62);
  static const Color icyBlue = Color(0xFF8EC5E8);

  static const Color textPrimary = Color(0xFFF3EEE2);
  static const Color textSecondary = Color(0xFFC9C4B8);
  static const Color onParchment = Color(0xFF2D2A25);
}

class StudyNSyncSpacing {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}

class StudyNSyncTextStyles {
  static TextTheme textTheme(ColorScheme colorScheme) {
    return const TextTheme(
      displaySmall: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        height: 1.15,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
      ),
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}

class StudyNSyncTheme {
  static ThemeData get darkAcademy {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: StudyNSyncColors.icyBlue,
      onPrimary: StudyNSyncColors.midnightBlue,
      secondary: StudyNSyncColors.mutedGold,
      onSecondary: StudyNSyncColors.midnightBlue,
      error: Color(0xFFE38B8B),
      onError: Colors.black,
      surface: StudyNSyncColors.charcoal,
      onSurface: StudyNSyncColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: StudyNSyncColors.deepNavy,
      canvasColor: StudyNSyncColors.deepNavy,
      textTheme: StudyNSyncTextStyles.textTheme(colorScheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: StudyNSyncColors.midnightBlue,
        foregroundColor: StudyNSyncColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: StudyNSyncColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: StudyNSyncColors.charcoal,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: StudyNSyncColors.mutedGold, width: 0.8),
        ),
        margin: const EdgeInsets.only(bottom: StudyNSyncSpacing.sm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StudyNSyncColors.mutedGold,
          foregroundColor: StudyNSyncColors.midnightBlue,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: StudyNSyncColors.mutedGold),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: StudyNSyncColors.icyBlue,
          side: const BorderSide(color: StudyNSyncColors.mutedGold, width: 1),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StudyNSyncColors.icyBlue,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StudyNSyncColors.charcoal,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: const TextStyle(color: StudyNSyncColors.textSecondary),
        hintStyle: const TextStyle(color: StudyNSyncColors.textSecondary),
        prefixIconColor: StudyNSyncColors.icyBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StudyNSyncColors.mutedGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StudyNSyncColors.mutedGold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: StudyNSyncColors.icyBlue, width: 1.5),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: StudyNSyncColors.icyBlue,
        textColor: StudyNSyncColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: StudyNSyncColors.mutedGold,
        thickness: 0.8,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: StudyNSyncColors.midnightBlue,
        contentTextStyle: TextStyle(color: StudyNSyncColors.textPrimary),
      ),
    );
  }
}
