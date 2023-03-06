import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({
    Key? key,
    required this.child,
    required this.shake,
    this.duration = const Duration(milliseconds: 200),
    // TODO: Future feature
    // this.period = const Duration(milliseconds: 200),
  }) : super(key: key);

  final Widget child;

  /// Trigger widget shake to start or end by changing this value
  final bool shake;

  final Duration duration;

  // TODO: Future feature
  // final Duration period;

  @override
  _ShakeWidgetState createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // TODO: Future feature
  // int get _cycles =>
  //     widget.duration.inMilliseconds ~/ widget.period.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 0.5,
      lowerBound: 0,
      upperBound: 1,
    );
    _animation = Tween<double>(begin: 1, end: -1)
        // .chain(Tween<double>(begin: -1, end: 1))
        // .chain(Tween<double>(begin: 1, end: 0))
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake) {
      // Future(() async {
      // await _controller.animateTo(-1);

      _controller.repeat(
          reverse: true,
          period: Duration(milliseconds: widget.duration.inMilliseconds ~/ 3));
      Future.delayed(widget.duration, () {
        _controller.animateTo(0.5).then((a) => _controller.stop());
      });
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((_animation.value) * 8, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
