import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

import '../../helpers/accept_eula.dart';
import '../../helpers/create_new_pin.dart';
import '../../helpers/create_password.dart';
import '../../helpers/parsers.dart';

Future<void> createWalletToTest(WidgetTester tester,
    {String walletName}) async {
  // create wallet to be used in following tests
  walletName ??= 'my-wallet';
  final Finder createWalletButton = find.byKey(const Key('createWalletButton'));
  final Finder nameField = find.byKey(const Key('name-wallet-field'));
  final Finder seedPhraseText = find.byKey(const Key('seed-phrase'));
  final Finder confirmSeedButton = find.byKey(const Key('create-seed-button'));
  final Finder copySeedButton = find.byKey(const Key('seed-copy'));
  final Finder reloadSeedButton = find.byKey(const Key('seed-refresh'));
  final Finder pressBackButton = find.byKey(const Key('check-phrase-again'));

  try {
    // =========== authenticate_page.dart =============== //
    await tester.pumpAndSettle();
    await tester.ensureVisible(createWalletButton);
    await tester.tap(createWalletButton);
    await tester.pumpAndSettle();

    // ============== welcome_page.dart ================== //
    await tester.tap(nameField);
    await tester.enterText(nameField, walletName);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);

    // ============= new_account_page.dart ================ //
    await tester.pump(Duration(seconds: 1));
    await tester.tap(reloadSeedButton);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(copySeedButton);
    await tester.pump(Duration(seconds: 1));
    final List<String> seedPhrase =
        tester.widget<Text>(seedPhraseText).data.split(' ');
    await tester.tap(confirmSeedButton);
    await tester.pump(Duration(seconds: 1));

    // =========== check_passphrase_page.dart =============== //
    await tester.tap(pressBackButton);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmSeedButton);
    await tester.pump(Duration(seconds: 1));

    await _confirmSeedPhrase(tester, seedPhrase);

    // =========== create_password_page.dart =============== //
    await createPassword(tester);

    // ============ disclaimer_page.dart =============== //
    await acceptEULA(tester);

    // ============== pin_page.dart ================== //
    await createNewPin(tester);
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}

Future<void> _confirmSeedPhrase(
  WidgetTester tester,
  List<String> seedPhrase,
) async {
  final Finder seedPhraseField = find.byKey(const Key('which-word-field'));
  final Finder whichWord = find.byKey(const Key('which-word'));
  final Finder continueCheckButton = find.byKey(const Key('continue-check'));

  // enter correct word
  int wordPosition = parseFirstInt(tester.widget<Text>(whichWord).data);
  await tester.enterText(seedPhraseField, seedPhrase[wordPosition - 1]);
  await tester.pump(Duration(seconds: 1));
  await tester.tap(continueCheckButton);
  await tester.pump(Duration(seconds: 1));

  // enter incorrect word
  wordPosition = parseFirstInt(tester.widget<Text>(whichWord).data);
  await tester.enterText(seedPhraseField, 'incorrect_word');
  await tester.pump(Duration(seconds: 1));
  expect(
    tester.widget<PrimaryButton>(continueCheckButton).onPressed == null,
    true,
    reason: 'Incorrect seed word entered,'
        ' but \'Continue\' button is enabled.',
  );

  // press correct button
  await tester.tap(find.text(seedPhrase[wordPosition - 1]));
  await tester.pump(Duration(seconds: 1));
  await tester.tap(continueCheckButton);
  await tester.pump(Duration(seconds: 1));

  // press incorrect button
  wordPosition = parseFirstInt(tester.widget<Text>(whichWord).data);
  final allWordButtons = tester.widgetList<ElevatedButton>(
    find.descendant(
      of: find.byKey(const Key('seed-word-buttons')),
      matching: find.byType(ElevatedButton),
    ),
  );
  for (ElevatedButton button in allWordButtons) {
    final text = button.child as Text;
    if (text.data == seedPhrase[wordPosition - 1]) continue;

    await tester.tap(find.text(text.data));
    await tester.pump(Duration(seconds: 1));
    expect(
      tester.widget<PrimaryButton>(continueCheckButton).onPressed == null,
      true,
      reason: 'Incorrect word button pressed,'
          ' but \'Continue\' button is enabled.',
    );
  }

  // press correct button
  wordPosition = parseFirstInt(tester.widget<Text>(whichWord).data);
  await tester.tap(find.text(seedPhrase[wordPosition - 1]));
  await tester.pump(Duration(seconds: 1));
  await tester.tap(continueCheckButton);
  await tester.pump(Duration(seconds: 1));
}
