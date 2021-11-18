import 'package:flutter/material.dart';

// TODO(MRC): The Flutter upgrade from the previous version to 2.5.x broke
// several parts of the theming, I will have to figure out how to fix later

SnackBarThemeData _snackBarTheme() => const SnackBarThemeData(
      elevation: 12.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      actionTextColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    );

// MRC: The properties of the themes have been greatly reduce so we can mostly
// foucs on colorScheme

ThemeData getThemeDark() => ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Ubuntu',
      textTheme: TextTheme(
        headline5: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headline6: const TextStyle(
          fontSize: 26.0,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        subtitle2: const TextStyle(fontSize: 18.0, color: Colors.white),
        bodyText2: const TextStyle(
          fontSize: 16.0,
          color: Colors.white,
          fontWeight: FontWeight.w300,
        ),
        button: const TextStyle(fontSize: 16.0, color: Colors.white),
        bodyText1:
            TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.5)),
        caption: TextStyle(
            fontSize: 12.0,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400),
      ),
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
      snackBarTheme: _snackBarTheme(),
    );
ThemeData getThemeLight() => ThemeData(
      fontFamily: 'Ubuntu',
      textTheme: TextTheme(
        headline5: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: Color.fromRGBO(24, 35, 49, 1),
        ),
        headline6: const TextStyle(
          fontSize: 26.0,
          color: Color.fromRGBO(24, 35, 49, 1),
          fontWeight: FontWeight.w700,
        ),
        subtitle2: const TextStyle(
            fontSize: 18.0, color: Color.fromRGBO(24, 35, 49, 1)),
        bodyText2: const TextStyle(
            fontSize: 16.0,
            color: Color.fromRGBO(24, 35, 49, 1),
            fontWeight: FontWeight.w300),
        button: const TextStyle(
            fontSize: 16.0, color: Color.fromRGBO(24, 35, 49, 1)),
        bodyText1: TextStyle(
            fontSize: 14.0,
            color: const Color.fromRGBO(24, 35, 49, 1).withOpacity(0.5)),
        caption: TextStyle(
          fontSize: 12.0,
          color: const Color.fromRGBO(24, 35, 49, 1).withOpacity(0.8),
          fontWeight: FontWeight.w400,
        ),
      ),
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
      snackBarTheme: _snackBarTheme(),
    );

const Color cexColor = Color.fromARGB(200, 253, 247, 227);

const Color cexColorLight = Color.fromRGBO(24, 35, 49, 0.6);
