import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/main.dart';

Future<void> addAddressToTest(WidgetTester tester,
    {String coin = 'AXE'}) async {
  print('ADD ADDRESS TO WALLET TEST');
  final Finder settingsMenu = find.byKey(const Key('main-nav-more'));
  final Finder addressBookButton = find.byKey(Key('side-nav-addressbook'));

  final Finder addressList = find.byKey(const Key('address-list'));
  final Finder editAddressButton = find.byKey(Key('edit-address-Address1'));
  final Finder editedAddressItem =
      find.byKey(Key('address-item-Edited-Address1'));
  final Finder addAddressPageButton =
      find.byKey(Key('add-address-page-button'));
  final Finder editedTitle = find.byKey(const Key('Edited-Address1'));
  final Finder addressItem = find.byKey(const Key('address-item-Address1'));

  try {
    expect(
      find.byType(MyHomePage),
      findsOneWidget,
      reason: 'Screen is not on the Home page',
    );
    await tester.tap(settingsMenu);
    await tester.pumpAndSettle();
    await tester.tap(addressBookButton);
    await tester.pumpAndSettle();
    await tester.tap(addAddressPageButton);
    await tester.pumpAndSettle();

    expect(
      addressItem,
      findsNothing,
      reason: 'Address Item is found but not yet added',
    );

    // add address
    await _createAddress(tester, coin);

    expect(
      addressItem,
      findsOneWidget,
      reason: 'Newly created Address Item not found',
    );
    // click the new created item
    await tester.dragUntilVisible(addressItem, addressList, Offset(0, -15));
    await tester.pumpAndSettle();
    await tester.tap(addressItem);
    await tester.pumpAndSettle();
    await tester.tap(editAddressButton);
    await tester.pumpAndSettle();

    // edit address
    await _editAddress(tester);
    expect(
      tester.widget<Text>(editedTitle).data,
      'Edited-Address1',
      reason: 'Edited Address name did not change',
    );
    await tester.dragUntilVisible(
        editedAddressItem, addressList, Offset(0, -15));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future<void> _createAddress(WidgetTester tester, String coin) async {
  final Finder selectedCoinAxe = find.byKey(Key('selected-coin-$coin'));
  final Finder nameField = find.byKey(const Key('name-address-field'));
  final Finder axeAddressField = find.byKey(Key('$coin-address-field'));
  final Finder saveButton = find.byKey(const Key('save-address'));
  final Finder addAddressButton = find.byKey(const Key('add-address'));
  final Finder selectCoinList = find.byKey(const Key('select-coin-list'));

  await tester.tap(addAddressButton);
  await tester.pumpAndSettle();
  expect(
    selectCoinList,
    findsOneWidget,
    reason: 'Coin List dialog is not found',
  );

  await tester.dragUntilVisible(
      selectedCoinAxe, selectCoinList, Offset(0, -50));
  await tester.pumpAndSettle();
  await tester.tap(selectedCoinAxe);
  await tester.pumpAndSettle();
  // test fails if a second `add address button` is present
  await tester.enterText(nameField, 'Address1');
  await tester.enterText(axeAddressField, 'bc1qxy2kgdygjrsp83kkfjhx0wlh');
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

Future<void> _editAddress(WidgetTester tester) async {
  final Finder selectedCoinBtc = find.byKey(const Key('selected-coin-BTC'));
  final Finder nameField = find.byKey(const Key('name-address-field'));
  final Finder btcAddressField = find.byKey(const Key('BTC-address-field'));
  final Finder saveButton = find.byKey(const Key('save-address'));
  final Finder selectCoinList = find.byKey(const Key('select-coin-list'));
  final Finder addAddressButton = find.byKey(const Key('add-address'));

  await tester.tap(addAddressButton);
  await tester.pumpAndSettle();
  expect(
    selectCoinList,
    findsOneWidget,
    reason: 'Coin List dialog is not found',
  );
  await tester.dragUntilVisible(
      selectedCoinBtc, selectCoinList, Offset(0, -15));

  await tester.tap(selectedCoinBtc);
  await tester.pumpAndSettle();
  // test fails if second address field is present
  await tester.enterText(nameField, 'Edited-Address1');
  await tester.enterText(btcAddressField, 'ssYEeurkbDFyrbeeUWuEjehjehwe788');
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}
