import 'package:flutter/material.dart';

class AnimatedCollapse extends StatefulWidget {
  const AnimatedCollapse({
    Key key,
    @required this.fullHeight,
    @required this.isCollapsed,
    @required this.child,
  }) : super(key: key);

  final Widget child;
  final bool isCollapsed;
  final double fullHeight;

  @override
  _AnimatedCollapseState createState() => _AnimatedCollapseState();
}

class _AnimatedCollapseState extends State<AnimatedCollapse>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: widget.fullHeight,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutExpo))
      ..addListener(() {
        setState(() {});
      });

    if (widget.isCollapsed) {
      _controller.value = 1.0; // set to collapsed
    }
  }

  @override
  void didUpdateWidget(AnimatedCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(shape: BoxShape.rectangle),
          height: _heightAnimation.value,
          child: _heightAnimation.value == 0 ? null : widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
