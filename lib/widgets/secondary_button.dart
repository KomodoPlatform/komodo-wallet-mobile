import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    Key key,
    @required this.onPressed,
    this.text,
    this.child,
    this.icon,
    this.isDarkMode = true,
    this.borderColor = Colors.black,
    this.height,
    this.width,
    this.textColor = Colors.black,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final Widget child;
  final Widget icon;
  final bool isDarkMode;
  final Color borderColor;
  final Color textColor;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    Widget finalChild = child;
    bool isSend = text != null && text == 'SEND';

    if (text != null) {
      finalChild = Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
      );
    }

    return SizedBox(
      height: height,

      // Please don't do this. It makes it difficult work with the widget in
      // situations where you want to constrain the button to take up as
      // little space as possible. Instead, let the parent widget handle
      // constraining the button.
      width: width ?? double.infinity,
      child: icon == null
          ? OutlinedButton(
              key: isSend ? const Key('secondary-button-send') : null,
              onPressed: onPressed,
              style: _getButtonStyle(context),
              child: finalChild,
            )
          : OutlinedButton.icon(
              key: isSend ? const Key('secondary-button-send') : null,
              onPressed: onPressed,
              style: _getButtonStyle(context),
              icon: icon,
              label: finalChild,
            ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
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
    );
  }
}
