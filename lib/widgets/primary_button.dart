import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
  })  : _color = null,
        super(key: key);

  /// Creates a PrimaryButton with a color scheme that contrasts with the
  /// default PrimaryButton. Use this to emphasise the CTA is more significant
  /// than the default PrimaryButton.
  const PrimaryButton.alternative({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
  })  : _color = const Color.fromARGB(255, 1, 102, 129),
        super(key: key);

  final Color? _color;

  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  /// Nullable. If null, then an ElevatedButton is used. Otherwise, an
  /// ElevatedButton.icon is used.
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: _color,
      minimumSize: const Size.fromHeight(48),
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
                  icon: icon!,
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
