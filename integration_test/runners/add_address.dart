import 'package:komodo_dex/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../tests/address/add_address_test.dart';
import '../tests/wallets_tests/restore_wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add Address test', (WidgetTester tester) async {
    tester.testTextInput.register();
    app.main();
    // delay for splash screen and checking updates
    await tester.pumpAndSettle();
    print('RESTORE WALLET TO TEST');
    await restoreWalletToTest(tester);
    await tester.pumpAndSettle();
    await addAddressToTest(tester);
  }, semanticsEnabled: false);
}
