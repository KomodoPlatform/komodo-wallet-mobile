import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../helpers/init_restore.dart';
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
    await tester.pumpAndSettle(Duration(seconds: 10));
/*
    print('TEST COINS ACTIVATION');
    await testActivateCoins(tester);

    print('TEST CEX PRICES');
    await testCexPrices(tester);

    print('TEST COINS DEACTIVATION');
    await testDisableCoin(tester);*/
  }, semanticsEnabled: false);
}
