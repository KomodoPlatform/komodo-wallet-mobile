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
    return Container(
      width: double.infinity,
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 16,),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),
        onPressed: widget.onPressed,
        color: Theme.of(context).accentColor,
        disabledColor: Theme.of(context).disabledColor,
        child: Text(
          widget.text.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .button
              .copyWith(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
