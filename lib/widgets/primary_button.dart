import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    Key key,
    @required this.onPressed,
    @required this.text,
    this.isLoading = false,
    this.isDarkMode = true,
    this.backgroundColor,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final bool isDarkMode;
  final Color backgroundColor;

  @override
  _PrimaryButtonState createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    if (widget.backgroundColor == null) {
      backgroundColor = Theme.of(context).colorScheme.secondary;
    } else {
      backgroundColor = widget.backgroundColor;
    }

    return SizedBox(
      width: double.infinity,
      child: widget.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                primary: backgroundColor,
                onPrimary: widget.isDarkMode
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(widget.text.toUpperCase()),
            ),
    );
  }
}
