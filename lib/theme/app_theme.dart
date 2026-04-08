import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/theme/button_theme.dart';
import 'package:shop/theme/input_decoration_theme.dart';

import '../constants.dart';
import 'checkbox_themedata.dart';
import 'theme_data.dart';

class AppTheme {
  static ThemeData lightTheme() {
    final baseTheme = ThemeData.light();
    final baseTextTheme = baseTheme.textTheme;
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: GoogleFonts.nunito().fontFamily,
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: blackColor),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE6E7EC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        baseTextTheme,
      ).copyWith(
        bodyLarge: GoogleFonts.nunito(color: blackColor),
        bodyMedium: GoogleFonts.nunito(color: blackColor80),
        bodySmall: GoogleFonts.nunito(color: blackColor60),
        titleMedium: GoogleFonts.nunito(
          color: blackColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(),
      inputDecorationTheme: lightInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: blackColor40),
      ),
      appBarTheme: appBarLightTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableLightThemeData,
    );
  }

  static ThemeData darkTheme() {
    final baseTheme = ThemeData.dark();
    final baseTextTheme = baseTheme.textTheme;
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.nunito().fontFamily,
      primarySwatch: primaryMaterialColor,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0F1117),
      cardColor: const Color(0xFF171A22),
      dividerColor: const Color(0xFF262B36),
      iconTheme: const IconThemeData(color: Colors.white),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF171A22),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        baseTextTheme,
      ).copyWith(
        bodyLarge: GoogleFonts.nunito(color: Colors.white),
        bodyMedium: GoogleFonts.nunito(color: whileColor80),
        bodySmall: GoogleFonts.nunito(color: whileColor60),
        titleMedium: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: elevatedButtonThemeData,
      textButtonTheme: textButtonThemeData,
      outlinedButtonTheme: outlinedButtonTheme(borderColor: whileColor20),
      inputDecorationTheme: darkInputDecorationTheme,
      checkboxTheme: checkboxThemeData.copyWith(
        side: const BorderSide(color: whileColor40),
      ),
      appBarTheme: appBarDarkTheme,
      scrollbarTheme: scrollbarThemeData,
      dataTableTheme: dataTableDarkThemeData,
    );
  }
}
