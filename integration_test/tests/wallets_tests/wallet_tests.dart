import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'create_wallet.dart';
import 'logout_wallet.dart';
import 'restore_old_wallet.dart';
import 'restore_wallet.dart';
import 'test_activate_coin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run wallet tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('CREATE WALLET TO TEST');
    await createWalletToTest(tester);
    print('LOGOUT WALLET TO WALLETS LIST');
    await logOut(tester);
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester, fromStart: false);
    await tester.pumpAndSettle();
    print('LOGOUT WALLET TO WALLETS LIST');
    await logOut(tester);
    await tester.pumpAndSettle();
    print('RESTORE WALLET FROM WALLETS LIST');
    await restoreOldWallet(tester);
    print('TEST COINS ACTIVATION');
    await testActivateCoins(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
