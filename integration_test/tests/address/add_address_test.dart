import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

Future<void> addAddressToTest(WidgetTester tester) async {
  print('ADD ADDRESS TO WALLET TEST');
  final Finder settingsMenu = find.byKey(const Key('main-nav-more'));
  final Finder addressBookButton =
      find.byKey(const Key('side-nav-addressbook'));
  final Finder addAddressPageButton =
      find.byKey(const Key('add-address-page-button'));
  final Finder addAddressButton = find.byKey(const Key('add-address'));
  final Finder selectedCoinAxe = find.byKey(const Key('selected-coin-AXE'));
  final Finder selectedCoinBtc = find.byKey(const Key('selected-coin-BTC'));
  final Finder nameField = find.byKey(const Key('name-address-field'));
  final Finder axeAddressField = find.byKey(const Key('AXE-address-field'));
  final Finder btcAddressField = find.byKey(const Key('BTC-address-field'));
  final Finder saveButton = find.byKey(const Key('save-address'));
  final Finder addressList = find.byKey(const Key('address-list'));
  final Finder selectCoinList = find.byKey(const Key('select-coin-list'));
  final Finder addressItem = find.byKey(const Key('address-item-Address1'));
  final Finder editAddressButton =
      find.byKey(const Key('edit-address-Address1'));
  final Finder editedAddressItem =
      find.byKey(const Key('address-item-Edited-Address1'));

  await tester.tap(settingsMenu);
  await tester.pumpAndSettle();
  await tester.tap(addressBookButton);
  await tester.pumpAndSettle();
  await tester.tap(addAddressPageButton);
  await tester.pumpAndSettle();
  await tester.tap(addAddressButton);
  await tester.pumpAndSettle();
  // add address
  await tester.tap(selectedCoinAxe);
  await tester.pumpAndSettle();
  // test fails if a second `add address button` is present
  await tester.enterText(nameField, 'Address1');
  await tester.enterText(axeAddressField, 'bc1qxy2kgdygjrsp83kkfjhx0wlh');
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
  await tester.dragUntilVisible(addressItem, addressList, Offset(0, -15));
  await tester.pumpAndSettle();
  await tester.tap(addressItem);
  await tester.pumpAndSettle();
  await tester.tap(editAddressButton);
  await tester.pumpAndSettle();
  // edit address
  await tester.tap(addAddressButton);
  await tester.pumpAndSettle();
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
  await tester.dragUntilVisible(editedAddressItem, addressList, Offset(0, -15));
  await tester.pumpAndSettle();
}
