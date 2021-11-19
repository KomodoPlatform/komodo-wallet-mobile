import 'package:flutter/material.dart';

class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    @required this.onPressed,
    this.text,
    this.child,
    this.isDarkMode = true,
    this.borderColor = Colors.black,
    this.height,
    this.width,
    this.textColor = Colors.black,
  });

  final VoidCallback onPressed;
  final String text;
  final Widget child;
  final bool isDarkMode;
  final Color borderColor;
  final Color textColor;
  final double height;
  final double width;

  @override
  _SecondaryButtonState createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  @override
  Widget build(BuildContext context) {
    Widget child;
    bool isSend = false;
    if (widget.text != null) {
      if (widget.text == 'SEND') {
        isSend = true;
      }
      child = Text(
        widget.text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      child = widget.child;
    }
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: OutlinedButton(
        key: isSend ? const Key('secondary-button-send') : null,
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          primary: Theme.of(context).brightness == Brightness.light
              ? widget.textColor
              : Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? widget.borderColor
                : Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: child,
      ),
    );
  }
}
