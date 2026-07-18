import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrahasthiTheme {
  // === Brand Colors ===
  static const Color saffron = Color(0xFFE8871E);
  static const Color saffronLight = Color(0xFFF5A623);
  static const Color saffronDark = Color(0xFFCC6A00);

  // === Background & Surface ===
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color cardBorder = Color(0xFF3A3A3A);

  // === Status Colors ===
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFE53935);
  static const Color yellow = Color(0xFFFFC107);
  static const Color blue = Color(0xFF42A5F5);

  // === Text Colors ===
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF666666);

  // === Category Colors (for grocery/reports) ===
  static const Color catVegetables = Color(0xFF66BB6A);
  static const Color catFruits = Color(0xFFFF7043);
  static const Color catDairy = Color(0xFF42A5F5);
  static const Color catGrains = Color(0xFFFFCA28);
  static const Color catSpices = Color(0xFFEF5350);
  static const Color catCleaning = Color(0xFF26C6DA);
  static const Color catPersonal = Color(0xFFAB47BC);
  static const Color catMedicine = Color(0xFFEC407A);
  static const Color catSnacks = Color(0xFFFFA726);
  static const Color catOther = Color(0xFF78909C);

  // === Tracker Card Icon Backgrounds ===
  static const Color milkIconBg = Color(0xFF3D3D3D);
  static const Color maidIconBg = Color(0xFF3D3520);
  static const Color groceryIconBg = Color(0xFF1B3D2A);
  static const Color creditIconBg = Color(0xFF3D3520);
  static const Color lpgIconBg = Color(0xFF3D1B1B);
  static const Color electricityIconBg = Color(0xFF2A2D3D);
  static const Color waterIconBg = Color(0xFF1B2D3D);
  static const Color watchmanIconBg = Color(0xFF3D2D1B);
  static const Color vehicleIconBg = Color(0xFF3D2D1B);
  static const Color emiIconBg = Color(0xFF3D1B3D);
  static const Color festivalIconBg = Color(0xFF3D3520);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: saffron,
      colorScheme: const ColorScheme.dark(
        primary: saffron,
        secondary: saffronLight,
        surface: surface,
        error: red,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: saffron,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: saffron,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: saffron,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: saffron),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: saffron, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: saffron,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: saffron,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return saffron;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return saffron.withOpacity(0.3);
          return cardBorder;
        }),
      ),
    );
  }
}
