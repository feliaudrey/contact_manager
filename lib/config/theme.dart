import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const turquoise = Color(0xFF55DDE0);
  static const tealBlue = Color(0xFF33658A);
  static const darkSlateGray = Color(0xFF2F4858);
  static const saffron = Color(0xFFF6AE2D);
  static const giantsOrange = Color(0xFFF26419);
}

class AppTheme {
  // Brand Colors
  static const brandDarkBlue = Color(0xFF002B5B);
  static const brandBlue = Color(0xFF00509D);
  static const brandAccent = Color(0xFFFF8C00);
  static const brandNeutral = Color(0xFF4A4A4A);

  // Base Colors
  static const base100 = Color(0xFF000000);
  static const base080 = Color(0xFF4D4D4D);
  static const base070 = Color(0xFF666666);
  static const base040 = Color(0xFF999999);
  static const base020 = Color(0xFFCCCCCC);
  static const base010 = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: brandBlue,
      secondary: brandAccent,
      surface: base010,
      background: base010,
      error: Colors.red.shade700,
      onPrimary: base010,
      onSecondary: base010,
      onSurface: base100,
      onBackground: base100,
      onError: base010,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: brandBlue,
      foregroundColor: base010,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: base010,
      selectedItemColor: brandBlue,
      unselectedItemColor: base070,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: brandAccent,
      foregroundColor: base010,
    ),
    cardTheme: CardTheme(
      color: base010,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: base010,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base040),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base040),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: brandBlue, width: 2),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: brandAccent,
      secondary: brandBlue,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: Color(0xFFCF6679),
      onPrimary: base010,
      onSecondary: base010,
      onSurface: base010,
      onBackground: base010,
      onError: base010,
      surfaceVariant: Color(0xFF2C2C2C),
      outline: base040,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: base010,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: brandAccent,
      unselectedItemColor: base040,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: brandAccent,
      foregroundColor: base010,
      elevation: 4,
    ),
    cardTheme: CardTheme(
      color: Color(0xFF2C2C2C),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base040),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: base040),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: brandAccent, width: 2),
      ),
      labelStyle: TextStyle(color: base020),
      hintStyle: TextStyle(color: base040),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: base010, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: base010, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: base010, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: base010, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: base010, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: base010, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: base010, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: base010),
      titleSmall: TextStyle(color: base020),
      bodyLarge: TextStyle(color: base010),
      bodyMedium: TextStyle(color: base020),
      bodySmall: TextStyle(color: base040),
      labelLarge: TextStyle(color: base010, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: base020),
      labelSmall: TextStyle(color: base040),
    ),
    dividerTheme: DividerThemeData(
      color: Color(0xFF2C2C2C),
      thickness: 1,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    dialogTheme: DialogTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF2C2C2C),
      contentTextStyle: TextStyle(color: base010),
      actionTextColor: brandAccent,
    ),
  );
} 