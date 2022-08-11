import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../tests/address/add_address_test.dart';
import '../tests/protocols/activate_test_coins.dart';
import '../tests/protocols/deactivate_test_coins.dart';
import '../tests/protocols/receive_test_coins.dart';
import '../tests/protocols/send_test_coins.dart';
import '../tests/protocols/tx_history_link.dart';
import '../tests/wallet_tests/restore_wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add kucoin protocol test', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester);
    await tester.pumpAndSettle();
    print('ACTIVATE KUCOIN COINS');
    await activateTestCoins(
      tester,
      coinsToActivate: ['KCS', 'SUSHI-KRC20', 'COMP-KRC20', 'LINK-KRC20'],
    );
    await tester.pumpAndSettle();
    print('DEACTIVATE KUCOIN COINS');
    await deactivateTestCoins(
      tester,
      coinsToDeactivate: ['COMP-KRC20', 'LINK-KRC20'],
    );
    print('RECEIVE COINS');
    await receiveTestCoins(
      tester,
      coins: ['KCS'],
    );
    await tester.pumpAndSettle();
    print('SEND COINS');
    await sendTestCoins(
      tester,
      address: '0x214FcA404a32AC668aec91Ca37D1A5F0BDB74736',
      coins: ['KCS'],
      amount: '0.001',
    );
    await tester.pumpAndSettle();
    print('ADD ADDRESS');
    await addAddressToTest(
      tester,
      coin: 'KCS',
    );
    await tester.pumpAndSettle();
    print('OPEN EXPLORER LINK');
    await openTxHistoryLink(
      tester,
      coins: ['KCS'],
    );
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
