import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../tests/address/add_address_test.dart';
import '../tests/protocols/activate_test_coins.dart';
import '../tests/protocols/deactivate_test_coins.dart';
import '../tests/protocols/receive_test_coins.dart';
import '../tests/protocols/send_test_coins.dart';
import '../tests/wallet_tests/restore_wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add ubiq protocol test', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester);
    await tester.pumpAndSettle();
    print('ACTIVATE UBIQ COIN');
    await activateTestCoins(tester, coinsToActivate: ['UBIQ']);
    await tester.pumpAndSettle();
    print('DEACTIVATE UBIQ COIN');
    await deactivateTestCoins(tester, coinsToDeactivate: ['UBIQ']);
    print('ACTIVATE UBIQ COIN AGAIN');
    await activateTestCoins(tester, coinsToActivate: ['UBIQ']);
    await tester.pumpAndSettle();
    print('RECEIVE COINS');
    await receiveTestCoins(tester, coins: ['UBIQ']);
    await tester.pumpAndSettle();
    print('SEND COINS');
    await sendTestCoins(
      tester,
      address: '0x214FcA404a32AC668aec91Ca37D1A5F0BDB74736',
      coins: ['UBIQ'],
      amount: '0.01',
    );
    await tester.pumpAndSettle();
    print('ADD ADDRESS');
    await addAddressToTest(tester, coin: 'UBIQ');
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
