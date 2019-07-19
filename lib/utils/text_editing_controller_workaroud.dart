import 'package:flutter/material.dart';

class TextEditingControllerWorkaroud extends TextEditingController {
  TextEditingControllerWorkaroud({String text}) : super(text: text);

  void setTextAndPosition(String newText, {int caretPosition}) {
    final int offset = caretPosition ??= newText.length;
    value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: offset),
        composing: TextRange.empty);
  }
}
