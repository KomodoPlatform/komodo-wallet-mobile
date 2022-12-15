import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import 'swaps/cancel_swap.dart';
import 'wallet_tests/restore_wallet.dart';
import 'swaps/activate_test_coins.dart';
import 'swaps/create_advanced_swap.dart';
import 'swaps/create_multi_swap.dart';
import 'swaps/create_simple_swap.dart';
import 'swaps/enable_test_coins.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const String firstWalletName = 'my-wallet';

  testWidgets('Run swap tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester, existingWalletName: firstWalletName);
    await tester.pumpAndSettle();
    print('ENABLE TEST COINS');
    await enableTestCoin(tester);
    await tester.pumpAndSettle();
    print('ACTIVATE TEST COINS');
    await activateTestCoins(tester,
        coinsToActivate: ['MORTY', 'RICK', 'tQTUM']);
    await tester.pumpAndSettle();
    print('CREATE A SIMPLE SWAP');
    await createSimpleSwap(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('swap-tab')));
    await tester.pumpAndSettle();
    print('CREATE AN ADVANCED SWAP');
    await tester.pumpAndSettle(Duration(seconds: 3));
    await createAdvancedSwap(tester);
    await tester.tap(find.byKey(Key('swap-tab')));
    await tester.pumpAndSettle();
    print('CREATE A MULTI SWAP');
    await createMultiSwap(tester);
    await tester.pumpAndSettle();
    print('CANCEL A SWAP');
    await cancelSwap(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
