import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;
  final Map<String, String> envVars = Platform.environment;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  group('Restore wallet', () {
    test('Name Wallet', () async {
      final SerializableFinder createWalletText = find.text('CREATE A WALLET');
      final SerializableFinder restoreWallet = find.text('RESTORE');
      final SerializableFinder titleWelcome = find.text('WELCOME');

      expect(await driver.getText(createWalletText), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.tap(restoreWallet);
      expect(await driver.getText(titleWelcome), 'WELCOME');

      final SerializableFinder nameWalletField =
          find.byValueKey('name-wallet-field');
      await driver.tap(nameWalletField);
      await driver.enterText('Mon super wallet');
      await driver.waitFor(find.text('Mon super wallet'));

      final SerializableFinder buttonNext = find.text('LET\'S GET SET UP!');
      await driver.tap(buttonNext);
    });

    test('Restore seed', () async {
      await driver.tap(find.byValueKey('restore-seed-field'));
      await driver.enterText(envVars['SEED']);
      await driver.tap(find.byValueKey('checkbox-custom-seed'));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('confirm-seed-button'));
    });

    test('Create password', () async {
      expect(await driver.getText(find.text('CREATE A PASSWORD')),
          'CREATE A PASSWORD');

      await driver.tap(find.byValueKey('create-password-field'));
      await driver.enterText('Qwertyuiopas-');
      await driver.waitFor(find.text('Qwertyuiopas-'));

      await driver.tap(find.byValueKey('create-password-field-confirm'));
      await driver.enterText('Qwertyuiopas-');
      await driver.waitFor(find.text('Qwertyuiopas-'));

      await driver.tap(find.text('CONFIRM PASSWORD'));
    });

    test('Validate disclaimer', () async {
      await driver.waitFor(find.text('Disclaimer & ToS'));
      await driver.scrollUntilVisible(find.byValueKey('scroll-disclaimer'),
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5000);
      await driver.tap(find.byValueKey('checkbox-eula'));
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('next-disclaimer'));
    });

    test('Create PIN', () async {
      await driver.waitFor(find.text('Create PIN'));
      expect(await driver.getText(find.text('Create PIN')), 'Create PIN');

      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('2'));
      }

      await driver.waitFor(find.text('Confirm PIN code'));
      expect(await driver.getText(find.text('Confirm PIN code')),
          'Confirm PIN code');

      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('2'));
      }
    });

    test('If coins default is here', () async {
      await driver.waitFor(find.text('KOMODO'));
      await driver.waitFor(find.text('BITCOIN'));
      await driver.waitFor(find.text('0 KMD'));
      await driver.waitFor(find.text('0 BTC'));
    });
  });

  group('Activates coins', () {
    final List<String> coinsToActivate = <String>[
      'BCH',
      'ETH',
      'DASH',
      'LTC',
      'USDC',
      'DOGE',
      'DGB',
      'QTUM',
      'RFOX',
      'ZILLA',
      'RVN',
      'VRSC',
      'BAT',
      'RICK',
      'MORTY'
    ];

    test('Activates all coins', () async {
      await driver.tap(find.byValueKey('adding-coins'));
      await driver.waitFor(find.text('ACTIVATE COINS:'));

      int i = 0;
      for (String coin in coinsToActivate) {
        print('coin-activate-$coin');
        await driver.tap(find.byValueKey('coin-activate-$coin'));
        if (i % 4 == 3) {
          await driver.scroll(find.byValueKey('coin-activate-$coin'), 0, -400,
              const Duration(milliseconds: 100));
        }
        i++;
      }

      await driver.tap(find.byValueKey('done-activate-coins'));
      coinsToActivate.insert(0, 'BTC');
      coinsToActivate.insert(0, 'KMD');
      await Future<void>.delayed(const Duration(seconds: 4), () {});

      i = 0;
      for (String coin in coinsToActivate) {
        if (i == coinsToActivate.length - 1) {
          await driver.scroll(find.byValueKey('list-view-coins'), 0, -300,
              const Duration(milliseconds: 100));
        }
        await driver.waitFor(find.byValueKey('coin-list-$coin'));
        if (i != coinsToActivate.length) {
          if (i == 0) {
            await driver.scroll(find.byValueKey('list-view-coins'), 0, -330,
                const Duration(milliseconds: 100));
          } else {
            await driver.scroll(find.byValueKey('list-view-coins'), 0, -140,
                const Duration(milliseconds: 100));
          }
        }

        i++;
      }
    });
  });
}
