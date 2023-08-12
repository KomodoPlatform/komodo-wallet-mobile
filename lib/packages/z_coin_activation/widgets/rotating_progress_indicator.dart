import 'package:flutter/material.dart';

class RotatingCircularProgressIndicator extends StatefulWidget {
  final double value;

  const RotatingCircularProgressIndicator({Key key, this.value})
      : super(key: key);

  @override
  _RotatingCircularProgressIndicatorState createState() =>
      _RotatingCircularProgressIndicatorState();
}

class _RotatingCircularProgressIndicatorState
    extends State<RotatingCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mustRotate = widget.value != null || widget.value < 0.1;

    return RotationTransition(
      turns: mustRotate
          ? Tween(begin: 0.0, end: 1.0).animate(controller)
          : AlwaysStoppedAnimation(0),
      child: CircularProgressIndicator.adaptive(
        value: widget.value,
        key: ValueKey('rotating_progress_indicator'),
      ),
    );
  }
}
