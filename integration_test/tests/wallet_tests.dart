import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'address/add_address_test.dart';
import 'wallet_tests/coin_icons.dart';
import 'wallet_tests/create_wallet.dart';
import 'wallet_tests/logout_wallet.dart';
import 'wallet_tests/restore_old_wallet.dart';
import 'wallet_tests/restore_wallet.dart';
import 'wallet_tests/test_activate_coin.dart';
import 'wallet_tests/test_protocol_filter.dart';

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
    print('LOGOUT WALLET TO WALLETS LIST');
    await logOut(tester);
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester, existingWalletName: firstWalletName);
    await tester.pumpAndSettle();
    print('LOGOUT WALLET TO WALLETS LIST');
    await logOut(tester);
    await tester.pumpAndSettle();
    print('RESTORE WALLET FROM WALLETS LIST');
    await restoreOldWallet(tester);
    await tester.pumpAndSettle();
    print('TEST COINS ICONS');
    await testCoinIcons(tester);
    await tester.pumpAndSettle();
    print('TEST COINS ACTIVATION');
    await testActivateCoins(tester);
    await tester.pumpAndSettle();
    print('TEST FILTER COINS BY PROTOCOL');
    await testCoinsProtocolFilter(tester);
    print('ADD ADDRESS TO TEST');
    await addAddressToTest(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
