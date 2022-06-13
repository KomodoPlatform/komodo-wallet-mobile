import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../helpers/init_restore.dart';
import '../../helpers/logout.dart';
import '../../helpers/restore_old_wallet.dart';
import 'test_activate_coin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run wallet tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle(Duration(seconds: 5));

    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester);
    await tester.pumpAndSettle(Duration(seconds: 2));
    print('LOGOUT WALLET TO WALLETS LIST');
    await logOut(tester);
    await tester.pumpAndSettle(Duration(seconds: 2));
    print('RESTORE WALLET FROM WALLETS LIST');
    await restoreOldWallet(tester);

    print('TEST COINS ACTIVATION');
    await testActivateCoins(tester);
/*
    print('TEST CEX PRICES');
    await testCexPrices(tester);

    print('TEST COINS DEACTIVATION');
    await testDisableCoin(tester);*/
  }, semanticsEnabled: false);
}
