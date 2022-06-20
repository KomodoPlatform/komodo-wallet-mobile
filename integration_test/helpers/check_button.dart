import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

void checkButtonStatus(WidgetTester tester, Finder finder, {bool skip = true}) {
  expect(tester.widget<PrimaryButton>(finder).onPressed != null, true,
      reason: 'Button disabled', skip: skip);
}
