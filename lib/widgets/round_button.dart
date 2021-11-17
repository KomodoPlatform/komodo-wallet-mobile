import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    @required this.onPressed,
    @required this.child,
    this.size = 50,
  });

  final Function onPressed;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                Theme.of(context).dialogBackgroundColor),
            elevation: MaterialStateProperty.all(0),
            padding: MaterialStateProperty.all(
              const EdgeInsets.all(0),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).primaryColorDark,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
            )),
        child: child,
      ),
    );
  }
}
