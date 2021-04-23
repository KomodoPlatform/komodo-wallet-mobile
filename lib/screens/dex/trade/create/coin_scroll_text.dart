import 'dart:async';

import 'package:flutter/material.dart';

class CoinScrollText extends StatefulWidget {
  const CoinScrollText(
      {Key key, this.abbr, this.style, this.maxLines, this.maxChar})
      : super(key: key);
  final String abbr;
  final TextStyle style;
  final int maxLines;
  final int maxChar;

  @override
  _CoinScrollTextState createState() => _CoinScrollTextState();
}

class _CoinScrollTextState extends State<CoinScrollText> {
  Timer _abbrTimer;
  Timer _scrollTimer;
  String currentAbbr = '-';

  final _scrollController = ScrollController();
  int speedFactor = 20;

  bool _shouldScroll = false;
  bool scrollReverse = false;
  bool isScrollRunning = false;

  final _textKey = GlobalKey();
  final _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _abbrTimer ??= Timer.periodic(Duration(milliseconds: 100), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (currentAbbr != widget.abbr) {
        setState(() {
          currentAbbr = widget.abbr;
          _shouldScroll = false;

          _scrollTimer?.cancel();

          _scrollTimer ??=
              Timer.periodic(Duration(milliseconds: 500), (t) async {
            if (!_shouldScroll) {
              final textWidth = _textKey.currentContext.size.width;
              final containerWidth = _containerKey.currentContext.size.width;

              _shouldScroll = textWidth > containerWidth;
            }
            if (!isScrollRunning) _scroll();
          });
        });
      }
    });
  }

  Future<void> _scroll({int delay = 1}) async {
    if (!mounted) return;

    while (_shouldScroll) {
      isScrollRunning = true;
      final textWidth = _textKey.currentContext.size.width;
      await _scrollController.animateTo(scrollReverse ? 0.0 : textWidth,
          duration: Duration(seconds: scrollReverse ? 1 : 2),
          curve: Curves.linear);

      await Future.delayed(Duration(seconds: delay), () {});

      scrollReverse = !scrollReverse;
    }
    isScrollRunning = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        key: _containerKey,
        height: 20,
        alignment: AlignmentDirectional.center,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Text(
            currentAbbr,
            key: _textKey,
            style: widget.style,
            maxLines: widget.maxLines,
          ),
        ));
  }

  @override
  void dispose() {
    _abbrTimer.cancel();
    super.dispose();
  }
}
