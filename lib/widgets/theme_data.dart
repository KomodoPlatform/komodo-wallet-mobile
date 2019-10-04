import 'package:flutter/material.dart';

SnackBarThemeData _snackBarTheme() => SnackBarThemeData(
    elevation: 12.0,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
    actionTextColor: Colors.green,
    behavior: SnackBarBehavior.floating,
  );

Color get primaryColor => const Color.fromRGBO(42, 54, 71, 1);

ThemeData getTheme() => ThemeData(
      snackBarTheme: _snackBarTheme(),
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      backgroundColor: const Color.fromRGBO(30, 42, 58, 1),
      primaryColorDark: primaryColor,
      accentColor: const Color.fromRGBO(65, 234, 213, 1),
      textSelectionColor:
          const Color.fromRGBO(65, 234, 213, 1).withOpacity(0.3),
      dialogBackgroundColor: primaryColor,
      fontFamily: 'Ubuntu',
      hintColor: Colors.white,
      errorColor: const Color.fromRGBO(220, 3, 51, 1),
      disabledColor: const Color.fromRGBO(201, 201, 201, 1),
      buttonColor: const Color.fromRGBO(39, 68, 108, 1),
      cursorColor: const Color.fromRGBO(65, 234, 213, 1),
      textSelectionHandleColor: const Color.fromRGBO(65, 234, 213, 1),
      textTheme: TextTheme(
          headline: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white),
          title: TextStyle(
              fontSize: 26.0, color: Colors.white, fontWeight: FontWeight.w700),
          subtitle: TextStyle(fontSize: 18.0, color: Colors.white),
          body1: TextStyle(
              fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w300),
          button: TextStyle(fontSize: 16.0, color: Colors.white),
          body2:
              TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.5)),
          caption: TextStyle(
              fontSize: 12.0,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400)),
    );
