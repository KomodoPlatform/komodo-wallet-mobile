import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../tests/swaps/activate_test_coins.dart';
import '../tests/swaps/create_multi_swap.dart';
import '../tests/swaps/enable_test_coins.dart';
import '../tests/wallet_tests/restore_wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const String firstWalletName = 'my-wallet';

  testWidgets('Create a multi Swap test', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
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
    print('CREATE AN MULTI SWAP');
    await createMultiSwap(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
