import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../wallet_tests/restore_wallet.dart';
import 'activate_test_coins.dart';
import 'create_simple_swap.dart';

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
    print('ACTIVATE TEST COINS');
    await activateTestCoins(tester);
    await tester.pumpAndSettle();
    print('CREATE A SWAP');
    await createSimpleSwap(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
