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
  int _spacesBefore = 0;
  int _spacesAfter = 0;
  bool _isScrollStart = true;
  bool _isScrollBefore = false;
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
      _spacesBefore = 0;
      _spacesAfter = 0;
      _isScrollStart = false;
    } else if (_isScrollBefore) {
      _scrollAbbrStart = 0;
      _scrollAbbrEnd = 1;
      _scrollAbbrLength = abbr.length;
      _spacesBefore = maxChar - 1;
      _spacesAfter = 0;
      _isScrollBefore = false;
    } else {
      if (_spacesBefore > 0) {
        _spacesBefore -= 1;
      }
      if (_scrollAbbrEnd < _scrollAbbrLength) {
        _scrollAbbrEnd += 1;
      }
      if (_scrollAbbrEnd > maxChar) {
        _scrollAbbrStart += 1;
      }
      if ((_scrollAbbrEnd - _scrollAbbrStart + _spacesAfter + _spacesBefore) <
          maxChar) {
        _spacesAfter += 1;
      }
      if (_spacesAfter >= maxChar - 1) {
        _isScrollBefore = true;
      }
    }

    // Unicode character U+2004
    const spaceCharacter = ' ';
    final r = (spaceCharacter * _spacesBefore) +
        abbr.substring(_scrollAbbrStart, _scrollAbbrEnd) +
        (spaceCharacter * _spacesAfter);
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
