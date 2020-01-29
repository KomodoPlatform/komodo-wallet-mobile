import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// #644: We want the password to be obscured most of the time
/// in order to workaround the problem of some devices ignoring `TYPE_TEXT_FLAG_NO_SUGGESTIONS`,
/// https://github.com/flutter/engine/blob/d1c71e5206bd9546f4ff64b7336c4e74e3f4ccfd/shell/platform/android/io/flutter/plugin/editing/TextInputPlugin.java#L93-L99
class PasswordVisibilityControl extends StatefulWidget {
  const PasswordVisibilityControl({this.onVisibilityChange});
  final void Function(bool) onVisibilityChange;

  @override
  _PasswordVisibilityControlState createState() => _PasswordVisibilityControlState();
}

class _PasswordVisibilityControlState extends State<PasswordVisibilityControl> {
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
      // NB: Both the long press and the tap start with `onTabDown`.
      onTapDown: (TapDownDetails details) {
        _tapStartPosition = details.globalPosition;
        _setObscureTo(false);
      },
      // #644: Most users expect the eye to react to the taps (behaving as a toggle)
      // whereas long press handling starts too late to produce any visible reaction.
      // Flashing the password for a few seconds in order not to befuddle the users.
      onTapUp: (TapUpDetails details) {
        _timer = Timer(const Duration(seconds: 2), () {
          _setObscureTo(true);
        });
      },
      onLongPressStart: (LongPressStartDetails details) {
        if (_timer != null) _timer.cancel();
      },
      onLongPressEnd: (LongPressEndDetails details) {
        _setObscureTo(true);
      },

      // #644: Fires when we press on the eye and *a few seconds later* drag the finger off screen.
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        if (_wasLongPressMoved(details.globalPosition)) {
          _setObscureTo(true);
        }
      },
      // #644: Fires when we press on the eye and *immediately* drag the finger off screen.
      onVerticalDragStart: (DragStartDetails details) {
        _setObscureTo(true);
      },
      onHorizontalDragStart: (DragStartDetails details) {
        _setObscureTo(true);
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