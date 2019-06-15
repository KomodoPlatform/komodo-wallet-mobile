import 'package:flutter/material.dart';

class SecondaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget child;
  final bool isDarkMode;
  final Color borderColor;
  final Color textColor;
  final double height;
  final double width;

  SecondaryButton(
      {@required this.onPressed,
      this.text,
      this.child,
      this.isDarkMode = true,
      this.borderColor = Colors.black,
      this.height,
      this.width,
      this.textColor = Colors.black});

  @override
  _SecondaryButtonState createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.text != null) {
      child = Text(
        widget.text.toUpperCase(),
        style: Theme.of(context).textTheme.button.copyWith(
            color: widget.isDarkMode ? Colors.white : widget.textColor),
      );
    } else {
      child = widget.child;
    }
    return Container(
      height: widget.height,
      width: double.infinity,
      child: OutlineButton(
        borderSide: BorderSide(
            color: widget.isDarkMode ? Colors.white : widget.borderColor),
        highlightedBorderColor:
            widget.isDarkMode ? Colors.white : widget.borderColor,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        onPressed: widget.onPressed,
        child: child,
      ),
    );
  }
}
