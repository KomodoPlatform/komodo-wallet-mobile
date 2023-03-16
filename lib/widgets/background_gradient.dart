import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(1.0372, 1.0207),
          radius: 1.9988,
          colors: [
            Color(0xFF0D2D59),
            Color(0xFF0E101B),
          ],
          stops: [
            0.0,
            0.4008,
          ],
        ),
      ),
      child: child,
    );
  }
}
