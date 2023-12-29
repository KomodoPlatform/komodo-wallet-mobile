// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:komodo_dex/screens/portfolio/activate/build_item_coin.dart';
import 'package:komodo_dex/utils/utils.dart';

import 'create_wallet.dart';

Future<void> testCoinIcons(WidgetTester tester) async {
  final Finder portfolioTab = find.byKey(const Key('main-nav-portfolio'));
  final Finder addAssetsButton = find.byKey(const Key('add-coin-button'));
  final Finder selectCoinList = find.byKey(const Key('list-select-coins'));
  final Finder firstCoinItem = find
      .descendant(of: selectCoinList, matching: find.byType(BuildItemCoin))
      .first;

  await tester.tap(portfolioTab);
  await tester.pumpAndSettle();
  await tester.tap(addAssetsButton);
  await tester.pumpAndSettle(Duration(seconds: 2));
  await tester.ensureVisible(firstCoinItem);

  final listSize = tester.getSize(selectCoinList);
  final scrollOffset = -listSize.height * 0.8;
  List<BuildItemCoin> previousItems = [];
  bool keepScrolling = true;
  while (keepScrolling) {
    final visibleListItems = find
        .byType(BuildItemCoin)
        .evaluate()
        .map((e) => e.widget as BuildItemCoin)
        .toList();

    // Iterate over the visible coins rather than the list widget because
    // the ListView controller is null, making it difficult to check
    // if the list is at the bottom
    for (var coinIcon in visibleListItems) {
      final assetPath = getCoinIconPath(coinIcon.coin.abbr);
      bool exists = await assetExists(assetPath);
      expect(exists, true, reason: 'Asset $assetPath does not exist');
    }

    // Use a drag gesture rather than scrollUntilVisible because the
    // end of the list is not static or known at this point
    await tester.drag(selectCoinList, Offset(0, scrollOffset));
    await tester.pumpAndSettle();

    // Compare the lists to determin when to stop scrolling
    if (listEquals(previousItems, visibleListItems)) {
      keepScrolling = false;
    }

    previousItems = visibleListItems;
  }
}

Future<bool> assetExists(String assetPath) async {
  bool assetExists = true;
  try {
    final _ = await rootBundle.load(assetPath);
  } catch (e) {
    print('Asset $assetPath does not exist');
    assetExists = false;
  }
  return assetExists;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String firstWalletName = 'my-wallet';

  testWidgets('Run wallet tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    await tester.pumpAndSettle();
    print('CREATE WALLET TO TEST');
    await createWalletToTest(tester, walletName: firstWalletName);
    await tester.pumpAndSettle();
    print('TEST COINS ICONS');
    await testCoinIcons(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
