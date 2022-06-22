import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../tests/swaps/activate_test_coins.dart';
import '../tests/swaps/create_simple_swap.dart';
import '../tests/wallets_tests/restore_wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create a Swap test', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester);
    await tester.pumpAndSettle();
    print('ACTIVATE TEST COINS');
    await activateTestCoins(tester);
    await tester.pumpAndSettle();
    print('CREATE A SIMPLE SWAP');
    await createSimpleSwap(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
