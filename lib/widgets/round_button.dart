import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.size = 50,
  }) : super(key: key);

  final Function onPressed;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed as void Function()?,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: child,
      ),
    );
  }
}
