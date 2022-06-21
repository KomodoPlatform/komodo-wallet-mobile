import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/check_button.dart';
import '../../helpers/enter_pin.dart';
import '../../helpers/parsers.dart';

Future<void> createWalletToTest(WidgetTester tester) async {
  // create wallet to be used in following tests
  try {
    const String walletName = 'my-wallet';
    const String invalidPassword = 'abcd';
    const String password = 'pppaaasssDDD555444@@@';
    const String wrongPassword = 'teretet';
    const String confirmPassword = 'pppaaasssDDD555444@@@';
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
    final Finder disclaimerButton = find.byKey(const Key('next-disclaimer'));

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

    int wordPosition = parseFirstInt(tester.widget<Text>(whichWord).data);
    await tester.enterText(seedPhraseField, seedPhrase[wordPosition - 1]);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(continueCheckButton);
    await tester.pump(Duration(seconds: 1));

    wordPosition = parseFirstInt(tester.widget<Text>(whichWord).data);
    await tester.enterText(seedPhraseField, seedPhrase[wordPosition - 1]);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(continueCheckButton);
    await tester.pump(Duration(seconds: 1));

    wordPosition = parseFirstInt(tester.widget<Text>(whichWord).data);
    await tester.enterText(seedPhraseField, seedPhrase[wordPosition - 1]);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(continueCheckButton);
    await tester.pump(Duration(seconds: 1));

    // =========== create_password_page.dart =============== //
    // test invalid password
    await tester.tap(passwordField);
    await tester.enterText(passwordField, invalidPassword);
    await tester.tap(passwordConfirmField);
    await tester.enterText(passwordConfirmField, invalidPassword);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmPasswordButton);
    await tester.pump(Duration(seconds: 1));
    expect(invalidPassword, password, reason: 'Invalid Password', skip: true);
    checkButtonStatus(tester, confirmPasswordButton);
    // test wrong password
    await tester.tap(passwordField);
    await tester.enterText(passwordField, password);
    await tester.tap(passwordConfirmField);
    await tester.enterText(passwordConfirmField, wrongPassword);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmPasswordButton);
    await tester.pump(Duration(seconds: 1));
    expect(wrongPassword, password, reason: 'Wrong Password', skip: true);
    checkButtonStatus(tester, confirmPasswordButton);
    //  correct password
    await tester.tap(passwordField);
    await tester.enterText(passwordField, password);
    await tester.tap(viewPasswordBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(passwordConfirmField);
    await tester.enterText(passwordConfirmField, confirmPassword);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmPasswordButton);
    await tester.pump(Duration(seconds: 1));
    // ============ disclaimer_page.dart =============== //
    await tester.tap(disclaimerButton);
    checkButtonStatus(tester, disclaimerButton);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(eulaCheckBox);
    await tester.tap(tocCheckBox);
    await tester.longPress(scrollButton);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(disclaimerButton);
    await tester.pump(Duration(seconds: 1));
    // ============== pin_page.dart ================== //
    await tester.pumpAndSettle();
    await enterPinCode(tester, pin: correctPin);
    await tester.pumpAndSettle();
    //check for wrong pin
    await enterPinCode(tester, pin: wrongPin);
    await tester.pumpAndSettle();
    expect(wrongPin, correctPin, reason: 'Wrong PIN', skip: true);
    await tester.pump(Duration(seconds: 1));
    await enterPinCode(tester, pin: correctPin);
    await tester.pumpAndSettle();
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
