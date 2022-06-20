import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import '../wallets_tests/restore_wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add Address test', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester);
    await tester.pumpAndSettle();
    print('ADD ADDRESS TO WALLET TEST');
    final Finder settingsMenu = find.byKey(const Key('main-nav-more'));
    final Finder addressBookButton =
        find.byKey(const Key('side-nav-addressbook'));
    final Finder addAddressPageButton =
        find.byKey(const Key('add-address-page-button'));
    final Finder addAddressButton = find.byKey(const Key('add-address'));
    final Finder selectedCoinAxe = find.byKey(const Key('selected-coin-AXE'));
    final Finder nameField = find.byKey(const Key('name-address-field'));
    final Finder addressField = find.byKey(const Key('AXE-address-field'));
    final Finder saveButton = find.byKey(const Key('save-address'));
    final Finder addressList = find.byKey(const Key('address-list'));
    final Finder addressItem = find.byKey(const Key('address-item-Address1'));

    await tester.tap(settingsMenu);
    await tester.pumpAndSettle();
    await tester.tap(addressBookButton);
    await tester.pumpAndSettle();
    await tester.tap(addAddressPageButton);
    await tester.pumpAndSettle();
    await tester.tap(addAddressButton);
    await tester.pumpAndSettle();
    await tester.tap(selectedCoinAxe);
    await tester.pumpAndSettle();
    // test fails if second address field is present
    await tester.enterText(nameField, 'Address1');
    await tester.enterText(addressField, 'bc1qxy2kgdygjrsp83kkfjhx0wlh');
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(addressItem, addressList, Offset(0, -15));
    await tester.pumpAndSettle();
    await tester.tap(addressItem);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
