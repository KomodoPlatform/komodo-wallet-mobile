import 'package:flutter/material.dart';

class AlignedIconButton extends StatelessWidget {
  const AlignedIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
    super.key,
  });

  final Icon icon;
  final Widget label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            label,
          ],
        ),
      ),
    );
  }
}
