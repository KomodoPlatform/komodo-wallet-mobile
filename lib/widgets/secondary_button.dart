import 'package:flutter/material.dart';

class SecondaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget child;
  final bool isDarkMode;

  SecondaryButton({@required this.onPressed,this.text, this.child, this.isDarkMode = true});

  @override
  _SecondaryButtonState createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.text != null) {
      child = Text(widget.text.toUpperCase(),style: Theme.of(context).textTheme.button.copyWith(color: widget.isDarkMode ? Colors.white : Theme.of(context).primaryColor),);
    } else {
      child = widget.child;
    }
    return Container(
      width: double.infinity,
      child: OutlineButton(
        borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Theme.of(context).primaryColor),
        highlightedBorderColor: widget.isDarkMode ? Colors.white : Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
        onPressed: widget.onPressed,
        child: child,
      ),
    );
  }
}