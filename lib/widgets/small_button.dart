import 'package:flutter/material.dart';

class SmallButton extends StatelessWidget {
  const SmallButton({
    @required this.onPressed,
    @required this.child,
    this.padding,
  });

  final Function onPressed;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: child,
    );
  }
}
