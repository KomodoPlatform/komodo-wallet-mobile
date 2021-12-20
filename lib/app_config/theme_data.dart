import 'package:flutter/material.dart';

// TODO(MRC): The Flutter upgrade from the previous version to 2.5.x broke
// several parts of the theming, I will have to figure out how to fix later

SnackBarThemeData _snackBarTheme = const SnackBarThemeData(
  behavior: SnackBarBehavior.floating,
);

AppBarTheme get _appBarTheme => const AppBarTheme(
      centerTitle: true,
    );

InputDecorationTheme get _inputDecorationTheme => const InputDecorationTheme(
      border: OutlineInputBorder(),
    );

DividerThemeData get _dividerThemeData => const DividerThemeData(
      space: 1,
    );

BottomNavigationBarThemeData get _bottomNavigationBarThemeData =>
    const BottomNavigationBarThemeData(
      backgroundColor: Color.fromRGBO(36, 39, 61, 1),
      unselectedItemColor: Color.fromRGBO(248, 248, 248, 1),
    );

TextSelectionThemeData get _textSelectionThemeData =>
    const TextSelectionThemeData(
        selectionColor: Color.fromRGBO(57, 161, 238, 0.3),
        cursorColor: Color.fromRGBO(57, 161, 238, 1));

// Color scheme dark adapted from current dev
ColorScheme get _colorScheme => const ColorScheme(
      primary: Color.fromRGBO(90, 104, 230, 1),
      primaryVariant: Color.fromRGBO(64, 78, 201, 1),
      secondary: Color.fromRGBO(60, 201, 191, 1),
      secondaryVariant: Color.fromRGBO(67, 46, 157, 1),
      surface: Color.fromRGBO(36, 39, 61, 1),
      background: Color.fromRGBO(32, 35, 55, 1),
      error: Color.fromRGBO(255, 255, 255, 1),
      onPrimary: Color.fromRGBO(255, 255, 255, 1),
      onSecondary: Color.fromRGBO(255, 255, 255, 1),
      onSurface: Color.fromRGBO(255, 255, 255, 1),
      onBackground: Color.fromRGBO(255, 255, 255, 1),
      onError: Color.fromRGBO(229, 33, 103, 1),
      brightness: Brightness.dark,
    );

// Color scheme light adapted from current dev
ColorScheme get _colorSchemeLight => const ColorScheme(
      primary: Color.fromRGBO(90, 104, 230, 1),
      primaryVariant: Color.fromRGBO(64, 78, 201, 1),
      secondary: Color.fromRGBO(60, 201, 191, 1),
      secondaryVariant: Color.fromRGBO(67, 46, 157, 1),
      surface: Color.fromRGBO(255, 255, 255, 1),
      background: Color.fromRGBO(248, 248, 248, 1),
      error: Color.fromRGBO(229, 33, 103, 1),
      onPrimary: Color.fromRGBO(255, 255, 255, 1),
      onSecondary: Color.fromRGBO(255, 255, 255, 1),
      onSurface: Color.fromRGBO(69, 96, 120, 1),
      onBackground: Color.fromRGBO(69, 96, 120, 1),
      onError: Color.fromRGBO(255, 255, 255, 1),
      brightness: Brightness.light,
    );

// MRC: The properties of the themes have been greatly reduced so we can mostly
// foucs on colorScheme

ThemeData getThemeDark() => ThemeData(
      fontFamily: 'Ubuntu',
      scaffoldBackgroundColor: const Color.fromRGBO(30, 42, 58, 1),
      dialogBackgroundColor: const Color.fromRGBO(42, 54, 71, 1),
      colorScheme: _colorScheme,
      snackBarTheme: _snackBarTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      dividerTheme: _dividerThemeData,
      bottomNavigationBarTheme: _bottomNavigationBarThemeData,
      textSelectionTheme: _textSelectionThemeData,
    );

ThemeData getThemeLight() => ThemeData(
      fontFamily: 'Ubuntu',
      scaffoldBackgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      dialogBackgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      colorScheme: _colorSchemeLight,
      snackBarTheme: _snackBarTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      dividerTheme: _dividerThemeData,
      bottomNavigationBarTheme: _bottomNavigationBarThemeData,
      textSelectionTheme: _textSelectionThemeData,
    );

const Color cexColor = Color.fromARGB(200, 253, 247, 227);

const Color cexColorLight = Color.fromRGBO(24, 35, 49, 0.6);

/// The SmallButton style for a ElevatedButton
/// Replaces the old SmallButton widget
ButtonStyle elevatedButtonSmallButtonStyle({EdgeInsets padding}) =>
    ElevatedButton.styleFrom(
      elevation: 0,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    );
