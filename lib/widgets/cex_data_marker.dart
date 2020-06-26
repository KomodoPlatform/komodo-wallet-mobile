import 'package:flutter/material.dart';

class CexMarker extends StatelessWidget {
  const CexMarker(this.context, {this.size = const Size(16, 16)});

  final Size size;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Icon(
          Icons.info_outline,
          size: size.height,
          color: const Color.fromARGB(255, 253, 247, 227),
        ),
    );
  }
}
