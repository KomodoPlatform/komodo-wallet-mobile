import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

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
  Timer _abbrUpdateTimer;
  String text = '-';

  @override
  void initState() {
    super.initState();

    _abbrUpdateTimer ??= Timer.periodic(Duration(milliseconds: 100), (t) {
      if (mounted) {
        if (text != widget.abbr) {
          setState(() {
            text = widget.abbr;
          });
        }
      } else {
        t.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      alignment: AlignmentDirectional.center,
      child: text.length > widget.maxChar
          ? Marquee(
              text: text,
              style: widget.style,
              blankSpace: 20.0,
            )
          : Text(
              text,
              style: widget.style,
              maxLines: widget.maxLines,
            ),
    );
  }

  @override
  void dispose() {
    _abbrUpdateTimer.cancel();
    super.dispose();
  }
}
