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

      var nameWalletField = find.byValueKey('name-wallet-field');
      await driver.tap(nameWalletField);
      await driver.enterText('Mon super wallet');
      await driver.waitFor(find.text('Mon super wallet'));

      var buttonNext = find.text("LET'S GET SET UP!");
      await driver.tap(buttonNext);

      var restoreSeedField = find.byValueKey('restore-seed-field');
      await driver.tap(restoreSeedField);
      await driver.enterText('test');
      await driver.waitFor(find.text('test'));
      await driver.tap(find.byValueKey("checkbox-custom-seed"));
      
      await driver.waitFor(find.text("CONFIRM"));
      await driver.tap(find.text("CONFIRM"));
      
      expect(await driver.getText(find.text("CREATE A PASSWORD")),  "CREATE A PASSWORD");

      var createPasswordField = find.byValueKey('create-password-field');
      var createPasswordFieldConfirm = find.byValueKey('create-password-field-confirm');
      
      await driver.tap(createPasswordField);
      await driver.enterText('Qwertyuiopas-');
      await driver.waitFor(find.text('Qwertyuiopas-'));
      
      await driver.tap(createPasswordFieldConfirm);
      await driver.enterText('Qwertyuiopas-');
      await driver.waitFor(find.text('Qwertyuiopas-'));
      
      await driver.tap(find.text("CONFIRM PASSWORD"));
      await driver.waitFor(find.text("Create PIN"));
      expect(await driver.getText(find.text("Create PIN")), "Create PIN");

    });

  });
}