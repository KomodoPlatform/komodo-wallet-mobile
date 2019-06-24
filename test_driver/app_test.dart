import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Atomix DEX', () {

    final createWalletText = find.text("CREATE A WALLET");
    final restoreWallet = find.text("RESTORE");
    final titleWelcome = find.text("WELCOME");


    FlutterDriver driver;
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Restore wallet', () async {
      expect(await driver.getText(createWalletText),  "CREATE A WALLET");
      expect(await driver.getText(restoreWallet),  "RESTORE");
      await driver.tap(restoreWallet);
      expect(await driver.getText(titleWelcome),  "WELCOME");
    });

  });
}