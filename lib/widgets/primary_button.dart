import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  PrimaryButton({@required this.onPressed, @required this.text});

  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 72),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
      onPressed: widget.onPressed,
      color: Theme.of(context).accentColor,
      child: Text(widget.text.toUpperCase(),style: Theme.of(context).textTheme.button.copyWith(color: Theme.of(context).primaryColor),),
    );
  }
}