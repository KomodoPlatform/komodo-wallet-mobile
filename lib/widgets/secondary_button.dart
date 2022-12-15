import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    Key key,
    @required this.onPressed,
    this.text,
    this.child,
    this.isDarkMode = true,
    this.borderColor = Colors.black,
    this.height,
    this.width,
    this.textColor = Colors.black,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final Widget child;
  final bool isDarkMode;
  final Color borderColor;
  final Color textColor;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    Widget child;
    bool isSend = false;
    if (text != null) {
      if (text == 'SEND') {
        isSend = true;
      }
      child = Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      child = child;
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        key: isSend ? const Key('secondary-button-send') : null,
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          primary: Theme.of(context).brightness == Brightness.light
              ? textColor
              : Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? borderColor
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
