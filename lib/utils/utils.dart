import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

copyToClipBoard(BuildContext context, String str) {
  Scaffold.of(context).showSnackBar(new SnackBar(
    duration: Duration(milliseconds: 300),
    content: new Text("Copied to the clipboard"),
  ));
  Clipboard.setData(new ClipboardData(text: str));
}