import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:pin_code_view/code_view.dart';

import '../../helpers/enter_pin.dart';
import '../../helpers/parsers.dart';

Future<void> createWalletToTest(WidgetTester tester) async {
  // create wallet to be used in following tests
  try {
    const String walletName = 'my-wallet';
    const String invalidPassword = 'abcd';
    const String password = 'pppaaasssDDD555444@@@';
    const String wrongPassword = 'teretet';
    const String correctPin = '123456';
    const String wrongPin = '123457';
    final Finder createWalletButton =
        find.byKey(const Key('createWalletButton'));
    final Finder nameField = find.byKey(const Key('name-wallet-field'));
    final Finder seedPhraseText = find.byKey(const Key('seed-phrase'));
    final Finder confirmSeedButton =
        find.byKey(const Key('create-seed-button'));
    final Finder copySeedButton = find.byKey(const Key('seed-copy'));
    final Finder reloadSeedButton = find.byKey(const Key('seed-refresh'));
    final Finder seedPhraseField = find.byKey(const Key('which-word-field'));
    final Finder whichWord = find.byKey(const Key('which-word'));
    final Finder continueCheckButton = find.byKey(const Key('continue-check'));
    final Finder pressBackButton = find.byKey(const Key('check-phrase-again'));
    final Finder passwordField = find.byKey(const Key('create-password-field'));
    final Finder passwordConfirmField =
        find.byKey(const Key('create-password-field-confirm'));
    final Finder confirmPasswordButton =
        find.byKey(const Key('confirm-password'));
    final Finder viewPasswordBtn = find.byKey(const Key('password-visibility'));
    final Finder eulaCheckBox = find.byKey(const Key('checkbox-eula'));
    final Finder tocCheckBox = find.byKey(const Key('checkbox-toc'));
    final Finder scrollButton =
        find.byKey(const Key('disclaimer-scroll-button'));
    final Finder disclaimerNextButton =
        find.byKey(const Key('next-disclaimer'));

    // =========== authenticate_page.dart =============== //
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

    // =========== create_password_page.dart =============== //
    // test invalid password
    await tester.enterText(passwordField, invalidPassword);
    await tester.enterText(passwordConfirmField, invalidPassword);
    await tester.pump(Duration(seconds: 1));
    expect(
      tester.widget<PrimaryButton>(confirmPasswordButton).onPressed == null,
      true,
      reason: 'Invalid password entered, but \'Confirm\' button is enabled',
    );

    // test wrong password
    await tester.enterText(passwordField, password);
    await tester.enterText(passwordConfirmField, wrongPassword);
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(
      tester.widget<PrimaryButton>(confirmPasswordButton).onPressed == null,
      true,
      reason: 'Passwords do not match, but \'Confirm\' button is enabled',
    );

    //  correct valid password
    await tester.enterText(passwordField, password);
    await tester.tap(viewPasswordBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(passwordConfirmField);
    await tester.enterText(passwordConfirmField, password);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmPasswordButton);
    await tester.pump(Duration(seconds: 1));

    // ============ disclaimer_page.dart =============== //
    expect(
      tester.widget<PrimaryButton>(disclaimerNextButton).onPressed == null,
      true,
      reason: 'Disclaimer page \'Next\' button is enabled on page load.',
    );
    await tester.tap(eulaCheckBox);
    await tester.tap(tocCheckBox);
    await tester.pump(Duration(seconds: 1));
    expect(
      tester.widget<PrimaryButton>(disclaimerNextButton).onPressed == null,
      true,
      reason: 'Disclaimer page is not scrolled to the end,'
          ' but  \'Next\' button is enabled.',
    );
    await tester.longPress(scrollButton);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(disclaimerNextButton);
    await tester.pump(Duration(seconds: 1));

    // ============== pin_page.dart ================== //
    await tester.pumpAndSettle();
    await enterPinCode(tester, pin: correctPin);
    await tester.pumpAndSettle();
    //check for wrong pin
    await enterPinCode(tester, pin: wrongPin);
    await tester.pump(Duration(seconds: 1));
    final codeView = find.byType(CodeView);
    final codeViewParent =
        find.ancestor(of: codeView, matching: find.byType(Column)).first;
    final errorText =
        find.descendant(of: codeViewParent, matching: find.byType(Text));
    expect(
      tester.widget<Text>(errorText).data.isNotEmpty,
      true,
      reason: 'Wrong confirmation PIN entered, but no error message shown.',
    );

    await enterPinCode(tester, pin: correctPin);
    await tester.pumpAndSettle();
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
