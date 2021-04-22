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
  String currentAbbr = '-';

  final _scrollController = ScrollController();
  int speedFactor = 20;

  bool startScroll = true;
  bool scrollReverse = false;

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
          if (currentAbbr.length > widget.maxChar) {
            startScroll = true;
          }
        });
        if (currentAbbr.length > widget.maxChar) {
          _scroll();
        }
      }
    });
  }

  void _scroll({int delay = 1}) {
    if (!mounted) return;
    if (!startScroll) return;

    startScroll = false;

    final maxExtent = _scrollController.position.extentInside;
    final durationDouble = maxExtent / speedFactor;

    _scrollController
        .animateTo(scrollReverse ? 0.0 : maxExtent,
            duration: Duration(seconds: durationDouble.toInt()),
            curve: Curves.linear)
        .then((_) {
      Future.delayed(Duration(seconds: delay), () {
        scrollReverse = !scrollReverse;
        startScroll = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 20,
        alignment: AlignmentDirectional.center,
        child: SingleChildScrollView(
          reverse: scrollReverse,
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Text(
            currentAbbr,
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
