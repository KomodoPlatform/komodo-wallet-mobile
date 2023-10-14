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
    with TickerProviderStateMixin {
  AnimationController rotationController;
  AnimationController progressController;
  Animation<double> progressAnimation;
  Animation<double> rotationAnimation;

  @override
  void initState() {
    super.initState();

    rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    rotationAnimation = CurvedAnimation(
      parent: rotationController,
      curve: Curves.slowMiddle,
    );

    progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    progressAnimation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: progressController,
      curve: Curves.easeOut,
    ));

    progressController.value = widget.value;
  }

  @override
  void didUpdateWidget(RotatingCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      progressAnimation = Tween<double>(
        begin: progressController.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: progressController,
        curve: Curves.easeOut,
      ));
      progressController.forward(from: progressController.value);
    }
  }

  @override
  void dispose() {
    rotationController.dispose();
    progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mustRotate = widget.value != null;

    return RotationTransition(
      turns: mustRotate ? rotationAnimation : AlwaysStoppedAnimation(0),
      child: AnimatedBuilder(
        animation: progressAnimation,
        builder: (BuildContext context, Widget child) {
          return CircularProgressIndicator(
            key: ValueKey('rotating_progress_indicator'),
            value: progressAnimation.value,
          );
        },
      ),
    );
  }
}
