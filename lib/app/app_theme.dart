import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color darkRed = Color(0xFF5C0000);
  static const Color bloodRed = Color(0xFFDC143C);
  static const Color deepBlack = Color(0xFF0A0A0A);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color smokeGray = Color(0xFF2A2A2A);
  static const Color lightGray = Color(0xFFB0B0B0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryRed,
        secondary: bloodRed,
        surface: charcoal,
        background: deepBlack,
        error: bloodRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightGray,
        onBackground: lightGray,
      ),
      scaffoldBackgroundColor: deepBlack,
      textTheme: GoogleFonts.crimsonTextTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: lightGray,
          displayColor: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.crimsonText(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: smokeGray,
        elevation: 8,
        shadowColor: primaryRed.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkRed.withOpacity(0.5), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          textStyle: GoogleFonts.crimsonText(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: bloodRed,
          side: const BorderSide(color: bloodRed, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.crimsonText(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: smokeGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkRed.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkRed.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: bloodRed, width: 2),
        ),
        labelStyle: GoogleFonts.crimsonText(color: lightGray),
        hintStyle: GoogleFonts.crimsonText(color: lightGray.withOpacity(0.6)),
      ),
      dividerTheme: DividerThemeData(
        color: darkRed.withOpacity(0.3),
        thickness: 1,
      ),
    );
  }

  static BoxDecoration get backgroundGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          deepBlack,
          charcoal,
          deepBlack,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  static BoxDecoration get cardGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          smokeGray,
          charcoal,
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: darkRed.withOpacity(0.5), width: 1),
      boxShadow: [
        BoxShadow(
          color: primaryRed.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
