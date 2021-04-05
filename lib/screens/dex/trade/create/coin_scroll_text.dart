import 'dart:async';

import 'package:flutter/material.dart';

class CoinScrollText extends StatefulWidget {
  const CoinScrollText({Key key, this.abbr, this.style, this.maxLines})
      : super(key: key);
  final String abbr;
  final TextStyle style;
  final int maxLines;

  @override
  _CoinScrollTextState createState() => _CoinScrollTextState();
}

class _CoinScrollTextState extends State<CoinScrollText> {
  Timer _scrollTimer;
  int _scrollAbbrStart = 0;
  int _scrollAbbrEnd = 0;
  int _scrollAbbrLength = 0;
  bool _isScrollStart = true;
  String text = '-';
  String currentCoin = '';

  String coinScroll(String abbr, {int maxChar}) {
    maxChar ??= 5;
    if (currentCoin != abbr) {
      currentCoin = abbr;
      _isScrollStart = true;
    }
    if (abbr.length <= maxChar) return abbr;
    if (_isScrollStart) {
      _scrollAbbrStart = 0;
      _scrollAbbrEnd = maxChar;
      _scrollAbbrLength = abbr.length;
      _isScrollStart = false;
    } else {
      _scrollAbbrStart += 1;
      _scrollAbbrEnd += 1;
      if (_scrollAbbrEnd >= _scrollAbbrLength) {
        _isScrollStart = true;
      }
    }

    final r = abbr.substring(_scrollAbbrStart, _scrollAbbrEnd);
    return r;
  }

  @override
  void initState() {
    super.initState();
    currentCoin = widget.abbr;
  }

  @override
  Widget build(BuildContext context) {
    _scrollTimer ??= Timer.periodic(Duration(milliseconds: 300), (t) {
      if (mounted) {
        final r = coinScroll(widget.abbr);
        setState(() {
          text = r;
        });
      } else {
        t.cancel();
      }
    });

    return Text(
      text,
      style: widget.style,
      maxLines: widget.maxLines,
    );
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    super.dispose();
  }
}
