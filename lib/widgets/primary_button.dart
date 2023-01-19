import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key key,
    @required this.onPressed,
    @required this.text,
    this.isLoading = false,
    this.isDarkMode = true,
    this.backgroundColor,
    this.icon,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final bool isDarkMode;
  final Color backgroundColor;

  /// Nullable. If null, then an ElevatedButton is used. Otherwise, an
  /// ElevatedButton.icon is used.
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      primary: backgroundColor ?? Theme.of(context).colorScheme.secondary,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    );

    final textWidget = Text(text.toUpperCase());

    return SizedBox(
      width: double.infinity,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : icon != null
              ? ElevatedButton.icon(
                  onPressed: onPressed,
                  style: buttonStyle,
                  icon: icon,
                  label: textWidget,
                )
              : ElevatedButton(
                  onPressed: onPressed,
                  style: buttonStyle,
                  child: textWidget,
                ),
    );
  }
}
