import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Credit for re-used legacy code from deleted file:
// lib/screens/authentification/authenticate_page.dart

class BoxButton extends StatelessWidget {
  const BoxButton({
    Key? key,
    required this.text,
    this.assetPath,
    this.onPressed,
  }) : super(key: key);

  final Widget text;
  final String? assetPath;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SvgPicture.asset(assetPath!, height: 40),
      ),
      label: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium ?? TextStyle(),
        child: text,
      ),
    );
  }
}
