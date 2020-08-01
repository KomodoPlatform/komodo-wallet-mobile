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
    return RaisedButton(
      onPressed: onPressed,
      child: child,
      color: Theme.of(context).dialogBackgroundColor,
      disabledColor: Theme.of(context).dialogBackgroundColor,
      elevation: 0,
      padding: padding,
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
