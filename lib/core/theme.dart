import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Your App's Color Scheme ---
const kPrimaryColor = Color(0xFF004D40);
const kLightScaffoldBgColor = Color(0xFFF8F9FA); // Light grey background
const kLightCardColor = Colors.white;

const kDarkScaffoldBgColor = Color(0xFF121212); // Standard dark
const kDarkCardColor = Color(0xFF1E1E1E); // Standard dark card

// ✅ --- ADDED THIS LINE ---
const kDestructiveColor = Colors.red;

class AppTheme {
  
  // --- Light Theme ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: kPrimaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        primary: kPrimaryColor,
        background: kLightScaffoldBgColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: kLightScaffoldBgColor,
      cardColor: kLightCardColor,
      
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: Colors.black87),

      appBarTheme: AppBarTheme(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // --- Dark Theme ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: kPrimaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        primary: kPrimaryColor,
        background: kDarkScaffoldBgColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: kDarkScaffoldBgColor,
      cardColor: kDarkCardColor,

      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: Colors.white70),
      
      appBarTheme: AppBarTheme(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}