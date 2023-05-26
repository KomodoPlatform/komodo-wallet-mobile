import 'package:flutter/material.dart';

@Deprecated("Use Flutter's [Badge] widget instead")
Widget buildRedDot(
  BuildContext context, {
  double? right = 0,
  double? left,
  double top = 0,
  double? bottom,
}) {
  return Positioned(
      right: right,
      top: top,
      left: left,
      bottom: bottom,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).bottomAppBarColor,
        ),
        width: 10,
        height: 10,
        child: Center(
            child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          width: 7,
          height: 7,
        )),
      ));
}
