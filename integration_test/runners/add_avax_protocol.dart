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

  testWidgets('Add avax protocol test', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester);
    await tester.pumpAndSettle();
    print('ACTIVATE AVAX COINS');
    await activateTestCoins(
      tester,
      coinsToActivate: ['AVAX', 'SUSHI-AVX20', 'DAI-AVX20', 'LINK-AVX20'],
    );
    await tester.pumpAndSettle();
    print('DEACTIVATE AVAX COINS');
    await deactivateTestCoins(
      tester,
      coinsToDeactivate: ['DAI-AVX20', 'LINK-AVX20'],
    );
    print('RECEIVE COINS');
    await receiveTestCoins(
      tester,
      coins: ['AVAX'],
    );
    await tester.pumpAndSettle();
    print('SEND COINS');
    await sendTestCoins(
      tester,
      address: '0x214FcA404a32AC668aec91Ca37D1A5F0BDB74736',
      coins: ['AVAX'],
      amount: '0.0001',
    );
    await tester.pumpAndSettle();
    print('ADD ADDRESS');
    await addAddressToTest(
      tester,
      coin: 'AVAX',
    );
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
