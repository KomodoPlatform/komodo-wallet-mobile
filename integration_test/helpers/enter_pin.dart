import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_code_view/custom_keyboard.dart';

Future<void> enterPinCode(
  WidgetTester tester, {
  @required String pin,
}) async {
  for (int i = 0; i < pin.length; i++) {
    final Finder digit = find.text(pin[i]);

    await tester.tap(find.ancestor(of: digit, matching: find.byType(NumPad)));
    await tester.pumpAndSettle();
  }
}
