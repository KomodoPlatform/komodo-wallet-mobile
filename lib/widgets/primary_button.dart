import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                primary:
                    backgroundColor ?? Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(text.toUpperCase()),
            ),
    );
  }
}
