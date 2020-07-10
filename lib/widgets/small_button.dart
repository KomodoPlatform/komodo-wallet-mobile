import 'package:flutter/material.dart';

class SmallButton extends StatelessWidget {
  const SmallButton({
    @required this.onPressed,
    @required this.child,
  });

  final Function onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
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
    );
  }
}
