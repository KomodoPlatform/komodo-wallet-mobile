import 'package:flutter/material.dart';

// TODO(MRC): The Flutter upgrade from the previous version to 2.5.x broke
// several parts of the theming, I will have to figure out how to fix later

SnackBarThemeData _snackBarTheme = const SnackBarThemeData(
  elevation: 12.0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  ),
  actionTextColor: Colors.green,
  behavior: SnackBarBehavior.floating,
);

AppBarTheme get _appBarTheme => AppBarTheme(
      elevation: 0,
      centerTitle: true,
    );

BottomNavigationBarThemeData get _bottomNavigationBarThemeData =>
    BottomNavigationBarThemeData(
      elevation: 0,
    );

ElevatedButtonThemeData get _elevatedButtonThemeData => ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
      ),
    );
InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
      border: OutlineInputBorder(),
    );

DividerThemeData get _dividerThemeData => DividerThemeData(
      color: Colors.white,
      space: 1,
    );

DividerThemeData get _dividerThemeDataLight => DividerThemeData(
      color: Colors.black,
      space: 1,
    );

// MRC: The properties of the themes have been greatly reduced so we can mostly
// foucs on colorScheme

ThemeData getThemeDark() => ThemeData(
      fontFamily: 'Ubuntu',
      colorScheme: const ColorScheme(
        primary: Color.fromRGBO(90, 104, 230, 1),
        primaryVariant: Color.fromRGBO(64, 78, 201, 1),
        secondary: Color.fromRGBO(106, 77, 227, 1),
        secondaryVariant: Color.fromRGBO(67, 46, 157, 1),
        surface: Color.fromRGBO(36, 39, 61, 1),
        background: Color.fromRGBO(32, 35, 55, 1),
        error: Color.fromRGBO(229, 33, 103, 1),
        onPrimary: Color.fromRGBO(255, 255, 255, 1),
        onSecondary: Color.fromRGBO(255, 255, 255, 1),
        onSurface: Color.fromRGBO(255, 255, 255, 1),
        onBackground: Color.fromRGBO(255, 255, 255, 1),
        onError: Color.fromRGBO(255, 255, 255, 1),
        brightness: Brightness.dark,
      ),
      snackBarTheme: _snackBarTheme,
      bottomNavigationBarTheme: _bottomNavigationBarThemeData,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonThemeData,
      inputDecorationTheme: _inputDecorationTheme,
      dividerTheme: _dividerThemeData,
    );
ThemeData getThemeLight() => ThemeData(
      fontFamily: 'Ubuntu',
      colorScheme: const ColorScheme(
        primary: Color.fromRGBO(90, 104, 230, 1),
        primaryVariant: Color.fromRGBO(64, 78, 201, 1),
        secondary: Color.fromRGBO(106, 77, 227, 1),
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
      ),
      snackBarTheme: _snackBarTheme,
      bottomNavigationBarTheme: _bottomNavigationBarThemeData,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonThemeData,
      inputDecorationTheme: _inputDecorationTheme,
      dividerTheme: _dividerThemeDataLight,
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
