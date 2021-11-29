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

// TODO(MRC): Try to fix ColorScheme by actually finding the correct colors for
// secondaryVariant and all the on- prefixed colors

// Color scheme dark adapted from current dev
ColorScheme get _colorScheme => const ColorScheme(
      primary: Color.fromRGBO(42, 54, 71, 1),
      primaryVariant: Color.fromRGBO(28, 36, 48, 1),
      secondary: Color.fromRGBO(57, 161, 238, 1),
      secondaryVariant:
          Color.fromRGBO(57, 161, 238, 1), // Currently set to same as secondary
      surface: Color.fromRGBO(42, 54, 71, 1),
      background: Color.fromRGBO(30, 42, 58, 1),
      error: Color.fromRGBO(202, 78, 61, 1),
      // All of those set to White
      onPrimary: Colors.white, // Currently set to white
      onSecondary: Colors.white, // Currently set to white
      onSurface: Colors.white, // Currently set to white
      onBackground: Colors.white, // Currently set to white
      onError: Colors.white, // Currently set to white
      brightness: Brightness.dark,
    );

// Color scheme light adapted from current dev
ColorScheme get _colorSchemeLight => const ColorScheme(
      // White breaks as primary breaks the color scheme, which would need many overrides
      // So copying the primary and primaryVariant of Dark theme for now
      primary: Color.fromRGBO(42, 54, 71, 1),
      primaryVariant: Color.fromRGBO(28, 36, 48, 1),
      secondary: Color.fromRGBO(60, 201, 191, 1),
      secondaryVariant:
          Color.fromRGBO(60, 201, 191, 1), // Currently set to same as secondary
      surface: Color.fromRGBO(255, 255, 255, 1),
      background: Color.fromRGBO(245, 245, 245, 1),
      error: Color.fromRGBO(202, 78, 61, 1),
      // Set to either black or white depending on contrast
      onPrimary: Colors.white, // Currently set to white
      onSecondary: Colors.white, // Currently set to white
      onSurface: Colors.black, // Currently set to black
      onBackground: Colors.black, // Currently set to black
      onError: Colors.white, // Currently set to white
      brightness: Brightness.light,
    );

// MRC: The properties of the themes have been greatly reduced so we can mostly
// foucs on colorScheme

ThemeData getThemeDark() => ThemeData(
      fontFamily: 'Ubuntu',
      colorScheme: _colorScheme,
      snackBarTheme: _snackBarTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      dividerTheme: _dividerThemeData,
    );

ThemeData getThemeLight() => ThemeData(
      fontFamily: 'Ubuntu',
      colorScheme: _colorSchemeLight,
      snackBarTheme: _snackBarTheme,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      dividerTheme: _dividerThemeData,
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
