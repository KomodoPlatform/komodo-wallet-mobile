import 'package:flutter/material.dart';

// TODO(MRC): The Flutter upgrade from the previous version to 2.5.x broke
// several parts of the theming, I will have to figure out how to fix later

SnackBarThemeData _snackBarTheme() => const SnackBarThemeData(
      elevation: 12.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4))),
      actionTextColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    );

Color get primaryColor => const Color.fromRGBO(42, 54, 71, 1);
Color get primaryColorLight => const Color.fromRGBO(255, 255, 255, 1);

ThemeData getThemeDark() => ThemeData(
      snackBarTheme: _snackBarTheme(),
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      backgroundColor: const Color.fromRGBO(30, 42, 58, 1),
      primaryColorDark: const Color.fromRGBO(28, 36, 48, 1),
      toggleableActiveColor: const Color.fromRGBO(57, 161, 238, 1),
      dialogBackgroundColor: primaryColor,
      fontFamily: 'Ubuntu',
      hintColor: Colors.white,
      errorColor: const Color.fromRGBO(202, 78, 61, 1),
      disabledColor: const Color.fromRGBO(201, 201, 201, 1),
      cardColor: primaryColor,
      textTheme: TextTheme(
          headline5: const TextStyle(
              fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white),
          headline6: const TextStyle(
              fontSize: 26.0, color: Colors.white, fontWeight: FontWeight.w700),
          subtitle2: const TextStyle(fontSize: 18.0, color: Colors.white),
          bodyText2: const TextStyle(
              fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w300),
          button: const TextStyle(fontSize: 16.0, color: Colors.white),
          bodyText1:
              TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.5)),
          caption: TextStyle(
              fontSize: 12.0,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400)),
    );
ThemeData getThemeLight() => ThemeData(
      snackBarTheme: _snackBarTheme(),
      brightness: Brightness.light,
      primaryColor: primaryColorLight,
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      primaryColorDark: const Color.fromRGBO(183, 187, 191, 1),
      toggleableActiveColor: const Color.fromRGBO(57, 161, 238, 1),
      dialogBackgroundColor: primaryColorLight,
      fontFamily: 'Ubuntu',
      hintColor: const Color.fromRGBO(183, 187, 191, 1),
      errorColor: const Color.fromRGBO(202, 78, 61, 1),
      disabledColor: const Color.fromRGBO(201, 201, 201, 1),
      cardColor: primaryColorLight,
      textTheme: TextTheme(
          headline5: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(24, 35, 49, 1)),
          headline6: const TextStyle(
              fontSize: 26.0,
              color: Color.fromRGBO(24, 35, 49, 1),
              fontWeight: FontWeight.w700),
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
              fontWeight: FontWeight.w400)),
    );

const Color cexColor = Color.fromARGB(200, 253, 247, 227);

const Color cexColorLight = Color.fromRGBO(24, 35, 49, 0.6);
