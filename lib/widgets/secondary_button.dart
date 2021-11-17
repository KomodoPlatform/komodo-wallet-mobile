import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';

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
        style: Theme.of(context).textTheme.button.copyWith(
            color: settingsBloc.isLightTheme ? widget.textColor : Colors.white),
      );
    } else {
      child = widget.child;
    }
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: OutlinedButton(
        key: isSend ? const Key('secondary-button-send') : null,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          side: MaterialStateProperty.all(
            BorderSide(
                color: settingsBloc.isLightTheme
                    ? widget.borderColor
                    : Colors.white),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
        onPressed: widget.onPressed,
        child: child,
      ),
    );
  }
}
