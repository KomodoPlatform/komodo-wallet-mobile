import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../wallet_tests/restore_wallet.dart';
import 'activate_test_coins.dart';
import 'check_testcoin_in_market.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const String firstWalletName = 'my-wallet';

  testWidgets('Check Test Coins Presence test', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester, existingWalletName: firstWalletName);
    await tester.pumpAndSettle();
    print('ACTIVATE TEST COINS');
    await activateTestCoins(tester);
    await tester.pumpAndSettle();
    print('CHECK TEST COIN PRESENCE');
    await checkTestCoinsInMarket(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
