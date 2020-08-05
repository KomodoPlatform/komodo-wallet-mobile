import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    @required this.onPressed,
    @required this.child,
    this.size = 50,
  });

  final Function onPressed;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RaisedButton(
        padding: const EdgeInsets.all(0),
        onPressed: onPressed,
        child: child,
        color: Theme.of(context).dialogBackgroundColor,
        disabledColor: Theme.of(context).dialogBackgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}
