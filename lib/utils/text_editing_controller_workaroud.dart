import 'package:flutter/material.dart';

//TODO(MRC): Figure out why this controller was created
// If it was due to a bug in the framework, check if the bug is fixed
// Otherwise, figure out how to make this work again
// For now I'm moving its usages back to TextEditingController

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
