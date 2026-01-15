import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryRed,
        secondary: AppColors.bloodRed,
        surface: AppColors.charcoal,
        background: AppColors.deepBlack,
        error: AppColors.bloodRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightGray,
        onBackground: AppColors.lightGray,
      ),
      scaffoldBackgroundColor: AppColors.deepBlack,
      textTheme: GoogleFonts.crimsonTextTextTheme(
        ThemeData.dark().textTheme.apply(
              bodyColor: AppColors.lightGray,
              displayColor: Colors.white,
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.crimsonText(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.smokeGray,
        elevation: 8,
        shadowColor: AppColors.primaryRed.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.darkRed.withOpacity(0.5), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
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
          foregroundColor: AppColors.bloodRed,
          side: const BorderSide(color: AppColors.bloodRed, width: 2),
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
        fillColor: AppColors.smokeGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkRed.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkRed.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bloodRed, width: 2),
        ),
        labelStyle: GoogleFonts.crimsonText(color: AppColors.lightGray),
        hintStyle: GoogleFonts.crimsonText(
          color: AppColors.lightGray.withOpacity(0.6),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkRed.withOpacity(0.3),
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
          AppColors.deepBlack,
          AppColors.charcoal,
          AppColors.deepBlack,
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
          AppColors.smokeGray,
          AppColors.charcoal,
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.darkRed.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryRed.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
