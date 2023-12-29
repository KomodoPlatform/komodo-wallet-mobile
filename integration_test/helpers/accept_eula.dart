import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

Future<void> acceptEULA(WidgetTester tester) async {
  final Finder eulaCheckBox = find.byKey(const Key('checkbox-eula'));
  final Finder tocCheckBox = find.byKey(const Key('checkbox-toc'));
  final Finder disclaimerNextButton = find.byKey(const Key('next-disclaimer'));

  expect(
    tester.widget<PrimaryButton>(disclaimerNextButton).onPressed == null,
    true,
    reason: 'Disclaimer page \'Next\' button is enabled on page load.',
  );
  await tester.tap(eulaCheckBox);
  await tester.tap(tocCheckBox);
  await tester.pump(Duration(seconds: 1));
  await tester.tap(disclaimerNextButton);
  await tester.pump(Duration(seconds: 1));
}
