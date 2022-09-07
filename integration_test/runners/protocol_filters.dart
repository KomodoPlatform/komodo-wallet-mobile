import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../tests/wallet_tests/create_wallet.dart';
import '../tests/wallet_tests/test_protocol_filter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Run wallet tests:', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('CREATE WALLET TO TEST');
    await createWalletToTest(tester);
    print('TEST PROTOCOL FILTER OF COINS');
    await testCoinsProtocolFilter(tester);
    await tester.pumpAndSettle();
  }, semanticsEnabled: false);
}
