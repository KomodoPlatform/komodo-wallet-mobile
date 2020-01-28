import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class PasswordVisibilityToggler extends StatefulWidget {
  const PasswordVisibilityToggler({this.onVisibilityChange});
  final void Function(bool) onVisibilityChange;

  @override
  _PasswordVisibilityTogglerState createState() => _PasswordVisibilityTogglerState();
}

class _PasswordVisibilityTogglerState extends State<PasswordVisibilityToggler> {
  Timer _timer;
  bool _isObscured = true;
  Offset _tapStartPosition;

  void _setObscureTo(bool isObscured) {
    if (_timer != null) _timer.cancel();
    setState(() {
      _isObscured = isObscured;
    });
    widget.onVisibilityChange(_isObscured);
  }

  bool _wasLongPressMoved(Offset position) {
    final double distance = sqrt(
        pow(_tapStartPosition.dx - position.dx, 2)
        + pow(_tapStartPosition.dy - position.dy, 2)
    );
    return distance > 20;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _tapStartPosition = details.globalPosition;
        _setObscureTo(false);
      },
      onTapUp: (TapUpDetails details) {
        _timer = Timer(Duration(seconds: 2), () {
          _setObscureTo(true);
        });
      },
      onVerticalDragStart: (DragStartDetails details) {
        _setObscureTo(true);
      },
      onHorizontalDragStart: (DragStartDetails details) {
        _setObscureTo(true);
      },
      onLongPressStart: (LongPressStartDetails details) {
        if (_timer != null) _timer.cancel();
      },
      onLongPressEnd: (LongPressEndDetails details) {
        _setObscureTo(true);
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        if (_wasLongPressMoved(details.globalPosition)) {
          _setObscureTo(true);
        }
      },
      child: SizedBox(
        width: 60,
        child: Container(
          child: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
          ),
        ),
      ),
    );
  }
}