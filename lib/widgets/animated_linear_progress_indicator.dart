import 'package:flutter/material.dart';

class AnimatedLinearProgressIndicator extends StatefulWidget {
  const AnimatedLinearProgressIndicator({
    Key key,
    @required this.value,
    // this.duration = const Duration(milliseconds: 200),
    this.duration = const Duration(milliseconds: 600),
    this.trackColor,
    this.progressColor,
  }) : super(key: key);

  /// Progress value between 0.0 and 1.0
  final double value;
  final Duration duration;
  final Color trackColor;
  final Color progressColor;

  @override
  _AnimatedLinearProgressIndicatorState createState() =>
      _AnimatedLinearProgressIndicatorState();
}

class _AnimatedLinearProgressIndicatorState
    extends State<AnimatedLinearProgressIndicator>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: widget.value,
      end: widget.value,
    ).animate(_controller)
      ..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(AnimatedLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linearProgressTheme = Theme.of(context).progressIndicatorTheme;
    final displayedTrackColor = widget.trackColor ??
        linearProgressTheme.linearTrackColor ??
        Theme.of(context).colorScheme.background;

    final displayedProgressColor =
        widget.progressColor ?? linearProgressTheme.color;

    final displayedHeight = linearProgressTheme.linearMinHeight ?? 4;

    return CustomPaint(
      painter: _ProgressBarPainter(
        progress: _animation.value,
        progressColor: displayedProgressColor,
        trackColor: displayedTrackColor,
      ),
      child: Container(height: displayedHeight),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({
    @required this.progress,
    @required this.trackColor,
    @required this.progressColor,
    //ignore: unused_element
    this.borderRadius = Radius.zero,
  }) : assert(progress != null && progress >= 0.0 && progress <= 1.0);

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Radius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      borderRadius,
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Clamp the progress between 0 and 1 to avoid any issues.
    final clampedProgress = progress.clamp(0.0, 1.0);

    final progressRect = RRect.fromRectAndRadius(
      Rect.fromPoints(
        Offset.zero,
        Offset(size.width * clampedProgress, size.height),
      ),
      borderRadius,
    );
    canvas.drawRRect(progressRect, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
