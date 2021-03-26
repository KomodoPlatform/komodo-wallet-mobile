import 'package:flutter/material.dart';

SnackBarThemeData _snackBarTheme() => SnackBarThemeData(
      elevation: 12.0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4))),
      actionTextColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    );

Color get primaryColor => const Color.fromRGBO(42, 54, 71, 1);
Color get primaryColorLight => const Color.fromRGBO(255, 255, 255, 1);

ThemeData getTheme() => ThemeData(
      snackBarTheme: _snackBarTheme(),
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      backgroundColor: const Color.fromRGBO(30, 42, 58, 1),
      primaryColorDark: const Color.fromRGBO(28, 36, 48, 1),
      accentColor: const Color.fromRGBO(57, 161, 238, 1),
      textSelectionColor:
          const Color.fromRGBO(57, 161, 238, 1).withOpacity(0.3),
      toggleableActiveColor: const Color.fromRGBO(57, 161, 238, 1),
      cursorColor: const Color.fromRGBO(57, 161, 238, 1),
      dialogBackgroundColor: primaryColor,
      fontFamily: 'Ubuntu',
      hintColor: Colors.white,
      errorColor: const Color.fromRGBO(220, 3, 51, 1),
      disabledColor: const Color.fromRGBO(201, 201, 201, 1),
      buttonColor: const Color.fromRGBO(39, 68, 108, 1),
      textSelectionHandleColor: const Color.fromRGBO(57, 161, 238, 1),
      cardColor: primaryColor,
      textTheme: TextTheme(
          headline5: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white),
          headline6: TextStyle(
              fontSize: 26.0, color: Colors.white, fontWeight: FontWeight.w700),
          subtitle2: const TextStyle(fontSize: 18.0, color: Colors.white),
          bodyText2: TextStyle(
              fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w300),
          button: const TextStyle(fontSize: 16.0, color: Colors.white),
          bodyText1:
              TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.5)),
          caption: TextStyle(
              fontSize: 12.0,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400)),
    );
ThemeData getTheme2() => ThemeData(
      snackBarTheme: _snackBarTheme(),
      brightness: Brightness.light,
      primaryColor: primaryColorLight,
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      primaryColorDark: const Color.fromRGBO(183, 187, 191, 1),
      accentColor: const Color.fromRGBO(60, 201, 191, 1),
      textSelectionColor:
      const Color.fromRGBO(57, 161, 238, 1).withOpacity(0.3),
      toggleableActiveColor: const Color.fromRGBO(57, 161, 238, 1),
      cursorColor: const Color.fromRGBO(57, 161, 238, 1),
      dialogBackgroundColor: primaryColorLight,
      fontFamily: 'Ubuntu',
      hintColor: const Color.fromRGBO(183, 187, 191, 1),
      errorColor: const Color.fromRGBO(220, 3, 51, 1),
      disabledColor: const Color.fromRGBO(201, 201, 201, 1),
      buttonColor: const Color.fromRGBO(60, 201, 191, 1),//const Color.fromRGBO(39, 68, 108, 1),
      textSelectionHandleColor: const Color.fromRGBO(57, 161, 238, 1),
      cardColor: primaryColorLight,
      textTheme: TextTheme(
          headline5: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w700, color: const Color.fromRGBO(24, 35, 49, 1)),
          headline6: TextStyle(
              fontSize: 26.0, color:const Color.fromRGBO(24, 35, 49, 1), fontWeight: FontWeight.w700),
          subtitle2: const TextStyle(fontSize: 18.0, color: Color.fromRGBO(24, 35, 49, 1)),
          bodyText2: TextStyle(
              fontSize: 16.0, color: const Color.fromRGBO(24, 35, 49, 1), fontWeight: FontWeight.w300),
          button: const TextStyle(fontSize: 16.0, color:  Color.fromRGBO(24, 35, 49, 1)),
          bodyText1:
          TextStyle(fontSize: 14.0, color: const Color.fromRGBO(24, 35, 49, 1).withOpacity(0.5)),
          caption: TextStyle(
              fontSize: 12.0,
              color: const Color.fromRGBO(24, 35, 49, 1).withOpacity(0.8),
              fontWeight: FontWeight.w400)),
);

const Color cexColor = Color.fromARGB(200, 253, 247, 227);

const Color cexColorLight = Color.fromRGBO(24, 35, 49, 0.6);