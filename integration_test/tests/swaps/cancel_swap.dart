import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'create_simple_swap.dart';

Future<void> cancelSwap(WidgetTester tester) async {
  final Finder yesBtn = find.byKey(const Key('settings-cancel-order-yes'));
  final Finder noBtn = find.byKey(const Key('settings-cancel-order-no'));
  final Finder askAgain = find.byKey(const Key('cancel-order-ask-again'));

  try {
    // create swap, cancel swap dialog and click yes
    await _swapAndCancel(tester);
    await tester.tap(yesBtn);
    await tester.pumpAndSettle();

    // create swap, cancel swap dialog and click no
    await _swapAndCancel(tester);
    await tester.tap(noBtn);
    await tester.pumpAndSettle();

    // cancel swap dialog and dont show again
    await _swapAndCancel(tester);
    await tester.tap(askAgain);
    await tester.pumpAndSettle();
    await tester.tap(yesBtn);
    await tester.pumpAndSettle();

    // create swap, cancel swap without dialog instantly
    await _swapAndCancel(tester);

    // Order has been cancelled
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}

Future<void> _swapAndCancel(WidgetTester tester) async {
  final Finder swapBtn = find.byKey(const Key('swap-tab'));
  final Finder cancelBtn = find.byType(OutlinedButton).first;
  await tester.tap(swapBtn);
  await tester.pumpAndSettle();
  await createSimpleSwap(tester);
  await tester.tap(cancelBtn);
  await tester.pumpAndSettle();
}
