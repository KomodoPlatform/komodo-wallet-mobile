import 'dart:async';

import 'package:flutter/material.dart';

class AutoScrollText extends StatefulWidget {
  const AutoScrollText({
    Key? key,
    this.text,
    this.style,
    this.delayBefore = const Duration(seconds: 2),
    this.duration = const Duration(seconds: 1),
    this.delayBetween = const Duration(milliseconds: 2000),
  }) : super(key: key);
  final String? text;
  final TextStyle? style;
  final Duration delayBefore;
  final Duration duration;
  final Duration delayBetween;

  @override
  _AutoScrollTextState createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _animate();
    });
  }

  @override
  void didUpdateWidget(covariant AutoScrollText oldWidget) {
    if (widget.text != oldWidget.text) {
      _scrollController?.jumpTo(0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Text(
        widget.text ?? '',
        style: widget.style,
      ),
    );
  }

  Future<void> _animate() async {
    await Future<dynamic>.delayed(widget.delayBefore);

    while (mounted) {
      await _scrollController?.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: widget.duration,
          curve: Curves.linear);
      await Future<dynamic>.delayed(Duration(milliseconds: 500));

      if (!mounted) break;
      await _scrollController?.animateTo(
          _scrollController.position.minScrollExtent,
          duration: widget.duration,
          curve: Curves.linear);
      await Future<dynamic>.delayed(widget.delayBetween);
    }
  }
}
