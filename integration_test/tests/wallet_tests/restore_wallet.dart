import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

import '../../helpers/accept_eula.dart';
import '../../helpers/create_new_pin.dart';
import '../../helpers/create_password.dart';

Future<void> restoreWalletToTest(WidgetTester tester,
    {String? existingWalletName}) async {
  // Restores wallet to be used in following tests
  const String seedPhrase =
      'hazard slam top rail jacket ecology trash first stock nut swift thought youth rack slot regular wasp bulk spatial legal staff change way brush';
  const String customSeed = 'hazard slam top';
  const String walletName = 'restored-wallet';
  final Finder restoreWalletButton = find.byKey(const Key('restoreWallet'));
  final Finder nameField = find.byKey(const Key('name-wallet-field'));
  final Finder confirmWalletNameButton = find.byKey(const Key('welcome-setup'));
  final Finder importSeedField = find.byKey(const Key('restore-seed-field'));
  final Finder confirmSeedButton = find.byKey(const Key('confirm-seed-button'));
  final Finder viewPasswordBtn = find.byKey(const Key('password-visibility'));

  try {
    // =========== authenticate_page.dart =============== //
    await tester.ensureVisible(restoreWalletButton);
    await tester.tap(restoreWalletButton);
    await tester.pumpAndSettle();

    // welcome_page.dart
    if (existingWalletName != null) {
      // already used name
      await tester.enterText(nameField, existingWalletName);
      await tester.pump(const Duration(seconds: 1));
      expect(
        tester.widget<PrimaryButton>(confirmWalletNameButton).onPressed == null,
        true,
        reason: 'Existing wallet name entered,'
            ' but \'Confirm\' button is enabled',
      );
    }
    await tester.tap(nameField);
    await tester.enterText(nameField, walletName);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(confirmWalletNameButton);

    // =========== restore_seed_page.dart =============== //
    // test custom seed
    await tester.pump(Duration(seconds: 1));
    await tester.enterText(importSeedField, customSeed);
    await tester.pump(Duration(seconds: 1));
    expect(
      tester.widget<PrimaryButton>(confirmSeedButton).onPressed == null,
      true,
      reason: 'Custom seed entered,'
          ' but \'Confirm\' button is enabled',
    );
    await tester.tap(viewPasswordBtn);

    // todo(yurii): add tests for 'Allow custom seed' checkbox/dialog

    // test correct seed
    await tester.enterText(importSeedField, seedPhrase);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(viewPasswordBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmSeedButton);
    await tester.pump(Duration(seconds: 1));

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
