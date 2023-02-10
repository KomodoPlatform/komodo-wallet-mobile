import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> enterPinCode(
  WidgetTester tester, {
  @required String pin,
}) async {
  for (int i = 0; i < pin.length; i++) {
    final Finder digit = find.text(pin[i]);
    // TODO: Rewrite this test to use the new pin input widget. May require
    //converting numpad and key from private widget to public.
    //   await tester
    //       .tap(find.ancestor(of: digit, matching: find.byType(CustomKeyboard)));
    //   await tester.pumpAndSettle();
  }
}
