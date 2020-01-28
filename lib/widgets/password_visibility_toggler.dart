import 'dart:async';
import 'package:flutter/material.dart';

class PasswordVisibilityToggler extends StatefulWidget {
  const PasswordVisibilityToggler({this.onVisibilityChange});
  final void Function(bool) onVisibilityChange;

  @override
  _PasswordVisibilityTogglerState createState() => _PasswordVisibilityTogglerState();
}

class _PasswordVisibilityTogglerState extends State<PasswordVisibilityToggler> {
  Timer timer;
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        if (timer != null) timer.cancel();
        setState(() {
          isObscured = false;
        });
        widget.onVisibilityChange(isObscured);
      },
      onTapUp: (TapUpDetails details) {
        timer = Timer(Duration(seconds: 2), () {
          setState(() {
            isObscured = true;
          });
          widget.onVisibilityChange(isObscured);
        });
      },
      onLongPressStart: (LongPressStartDetails details) {
        if (timer != null) timer.cancel();
      },
      onLongPressEnd: (LongPressEndDetails details) {
        setState(() {
          isObscured = true;
        });
        widget.onVisibilityChange(isObscured);
      },
      child: SizedBox(
        width: 60,
        child: Container(
          child: Icon(
            isObscured ? Icons.visibility_off : Icons.visibility,
          ),
        ),
      ),
    );
  }
}