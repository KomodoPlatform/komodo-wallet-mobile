import 'package:flutter/material.dart';

class TitleCoin extends StatefulWidget {
  const TitleCoin({Key key, @required this.text, this.style, this.tag})
      : super(key: key);

  final String text;
  final TextStyle style;
  final String tag;

  @override
  _TitleCoinState createState() => _TitleCoinState();
}

class _TitleCoinState extends State<TitleCoin> {
  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: widget.tag,
        child: Text(widget.text, style: widget.style));
  }
}
