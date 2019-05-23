import 'package:flutter/material.dart';

class SecondaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget child;

  SecondaryButton({@required this.onPressed,this.text, this.child});

  @override
  _SecondaryButtonState createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.text != null) {
      child = Text(widget.text.toUpperCase(),style: Theme.of(context).textTheme.button,);
    } else {
      child = widget.child;
    }
    return Container(
      width: double.infinity,
      child: OutlineButton(
        borderSide: BorderSide(color: Colors.white),
        highlightedBorderColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
        onPressed: widget.onPressed,
        child: child,
      ),
    );
  }
}