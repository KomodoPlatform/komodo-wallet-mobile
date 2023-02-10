// A widget which takes a child widget and a shake controller and shakes the child widget when the controller is triggered.

import 'package:flutter/material.dart';

/// NB: This is a WIP and is currently disabled
class Shake extends StatefulWidget {
  final bool active;
  final int cycles;
  final double amplitude;
  final Widget child;

  const Shake.x({
    @required this.active,
    this.cycles = 3,
    this.amplitude = 4,
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _ShakeState createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  int _currentCycles = 0;
  AnimationController _controller;
  Animation _animation;

  bool get _isActive => widget.active && _currentCycles < widget.cycles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    _animation = Tween(begin: 0, end: widget.amplitude)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentCycles++;
            if (_currentCycles == widget.cycles) {
              _controller.stop();
            }
          });
        }
      });
  }

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) {
      _controller.repeat(
        reverse: true,
        min: 0,
        max: 1,
        period: Duration(milliseconds: 50),
      );
      _currentCycles = 0;
    } else {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset.zero,
      // offset: Offset(_animation.value * widget.amplitude - widget.amplitude, 0),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
