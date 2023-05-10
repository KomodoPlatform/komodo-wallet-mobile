import 'package:flutter/material.dart';

class CircularAvatarButton extends StatelessWidget {
  final Widget child;
  final Color? color;
  final VoidCallback? onPressed;

  const CircularAvatarButton({
    required this.child,
    this.onPressed,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onHover: (value) {},
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.all(16),
          backgroundColor:
              color ?? Theme.of(context).colorScheme.primaryContainer,
          side: BorderSide(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          visualDensity: VisualDensity.compact,
        ),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.labelLarge!,
          child: child,
        ),
      ),
    );
  }
}
