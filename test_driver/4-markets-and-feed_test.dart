// ignore_for_file: file_names

import 'dart:math';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;
  final rnd = Random();
  const password = '           a';
  int globalDelay() => 500 + rnd.nextInt(500);
  const testNewWalletName = 'testNewWalletName';

  //------------------------------ Scenario 4 Finders ----------------------------------------//   - 1 Restore Wallet Screen
  //                Scenario 4 is reserved for creation of a new wallet.                      //   - 2 Create Wallet Name Screen
  //--------(Scenario 4)------- Restore A Wallet Screens --------(Scenario 4)-----------------//   - 3 Enter Your Seed Screen
  final SerializableFinder restoreWalletScreen =
      find.text('RESTORE'); //   - 4 Create Password Screen
  final SerializableFinder createWalletScreen =
      find.text('CREATE A WALLET'); //   - 5 Accept Disclaimer Screen
  final SerializableFinder createWalletNameScreen =
      find.text('WELCOME'); //   - 6 Create PIN Code Screen
  final SerializableFinder enterYourSeedScreen =
      find.text('Enter Your Seed Phrase'); //   - 7 Portfolio Screen
  final SerializableFinder createPasswordScreen =
      find.text('CREATE A PASSWORD'); //   - 8 Markets Screen
  final SerializableFinder disclaimerScreen =
      find.text('Disclaimer & ToS'); //   - 9 Feed Screen
  final SerializableFinder createaPINScreen =
      find.text('Create PIN'); //   - 10 Setting Screen (Delete Wallet)
  final SerializableFinder marketsPriceScreen = find.text('PRICE'); //
  final SerializableFinder marketsOrderBookScreen = find.text('ORDER BOOK'); //
  final SerializableFinder settingsScreen =
      find.byValueKey('settings-title'); //
  //------------------------------------------------------------------------------------------//
  /*--------*/ final SerializableFinder back =
      find.byTooltip('Back'); /*---------------------*/
  //---------------------- 1 - Restore wallet screen -----------------------------------------//
  final SerializableFinder restoreWalletBtn =
      find.byValueKey('restoreWallet'); //
  //---------------------- 2 - Create wallet name screen  ------------------------------------//
  final SerializableFinder welcomeScrollable =
      find.byValueKey('welcome-scrollable'); //
  final SerializableFinder nameWalletField =
      find.byValueKey('name-wallet-field'); //
  final SerializableFinder setup = find.text('LET\'S GET SET UP!'); //
  //---------------------- 3 - Enter Your Seed Screen  ---------------------------------------//
  final SerializableFinder restoreSeedField =
      find.byValueKey('restore-seed-field'); //
  final SerializableFinder confirmSeedBtn =
      find.byValueKey('confirm-seed-button'); //
  final SerializableFinder allowCustomSeed =
      find.byValueKey('checkbox-custom-seed'); //
  //---------------------- 4 - Create password screen  ---------------------------------------//
  final SerializableFinder passwordCreate =
      find.byValueKey('create-password-field'); //
  final SerializableFinder passwordRetype =
      find.byValueKey('create-password-field-confirm'); //
  final SerializableFinder passwordConfirm = find.text('CONFIRM PASSWORD'); //
  //---------------------- 5 - Accept disclaimer screen  -------------------------------------//
  final SerializableFinder disclamerScrollable =
      find.byValueKey('scroll-disclaimer'); //
  final SerializableFinder endDisclamerScrollable =
      find.byValueKey('end-list-disclaimer'); //
  final SerializableFinder checkEula = find.byValueKey('checkbox-eula'); //
  final SerializableFinder checkTOC = find.byValueKey('checkbox-toc'); //
  final SerializableFinder disclaimerNext =
      find.byValueKey('next-disclaimer'); //
  //---------------------- 6 - Create PIN Code screen ----------------------------------------//
  //   Its better not to expect() Create/Confirm PIN code, driver gets confused.              //
  //---------------------- 7 - Portfolio Screen ----------------------------------------------//
  final SerializableFinder bitcoin = find.text('BITCOIN'); //
  final SerializableFinder komodo = find.text('KOMODO'); //
  //---------------------- 8 - Markets Screen ------------------------------------------------//
  final SerializableFinder markets = find.byValueKey('main-nav-markets'); //
  final SerializableFinder marketsPriceBtn = find.text('PRICE'); //
  final SerializableFinder marketsOrderBookBtn = find.text('ORDER BOOK'); //
  final SerializableFinder marketsSelectCoinPopupScreen =
      find.text('Select Coin'); //
  final SerializableFinder marketsOrderBookEmptyScreen =
      find.text('Please select coins'); //
  final SerializableFinder marketsOrderBookTable =
      find.byValueKey('order-book-table'); //
  final SerializableFinder marketsCoinSelectLeft =
      find.byValueKey('coin-select-left'); //
  final SerializableFinder marketsCoinSelectRight =
      find.byValueKey('coin-select-right'); //
  final SerializableFinder marketsCoinSelectSwap =
      find.byValueKey('coin-select-swap'); //
  final SerializableFinder marketsCoinSelectClear = find.text('Clear'); //
  final SerializableFinder marketsCoinSelectBTC =
      find.byValueKey('coin-select-option-BTC'); //
  final SerializableFinder marketsCoinSelectKMD =
      find.byValueKey('coin-select-option-KMD'); //
  //---------------------- 9 - Feed Screen ---------------------------------------------------//
  final SerializableFinder feed = find.byValueKey('main-nav-feed'); //
  final SerializableFinder feedScreen = find.text('NEWS FEED'); //
  //---------------------- 10 - Settings Screen ----------------------------------------------//
  final SerializableFinder settings = find.byValueKey('side-nav-settings'); //
  final SerializableFinder more = find.byValueKey('main-nav-more'); //
  final SerializableFinder settingsScrollable =
      find.byValueKey('settings-scrollable'); //
  final SerializableFinder settingsDeleteWallet = find.text('Delete Wallet'); //
  final SerializableFinder enterPasswordField =
      find.byValueKey('enter-password-field'); //
  final SerializableFinder unlock = find.byValueKey('unlock-wallet'); //
  final SerializableFinder delete = find.byValueKey('delete-wallet'); //
  //--------------------------------------END-------------------------------------------------//
  //--------------------------END-(Scenario-4-Finders)-END------------------------------------//
  //--------------------------------------END-------------------------------------------------//

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  group('Driver Health |', () {
    test('-0- | Print flutter driver health', () async {
      final Health health = await driver.checkHealth();
      print(health.status);
    });

    test('-0.1- | For experiments', () async {
      print('Enough with experiments for now!');
    });
  });

  group('|  (Scenario 4) Markets, Feed and Settings  ', () {
    test('| -4.1- | Check restore-wallet-btn works', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });

    //(1)back-btn test from wallet-naming-screen
    test('| -4.2- | Check back-btn from wallet-naming-screen works', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    });

    test('| -4.3- | Check restore-wallet-btn works (2nd time)', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });

    test('| -4.4- | Create wallet name', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText(testNewWalletName);
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(
          await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');
    });

    test('| -4.5- | Restore wallet from seed "a" ', () async {
      expect(
          await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');

      await driver.waitFor(restoreSeedField);
      await driver.tap(restoreSeedField);
      await driver.enterText('a');
      await driver.waitFor(allowCustomSeed);
      await driver.tap(allowCustomSeed);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(confirmSeedBtn);
      await driver.tap(confirmSeedBtn);

      expect(await driver.getText(createPasswordScreen), 'CREATE A PASSWORD');
    });

    test('| -4.6- | Create password', () async {
      expect(await driver.getText(createPasswordScreen), 'CREATE A PASSWORD');

      await driver.waitFor(passwordCreate);
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await driver.waitFor(passwordRetype);
      await driver.tap(passwordRetype);
      await driver.enterText(password);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(passwordConfirm);
      await driver.tap(passwordConfirm);

      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');
    });

    test('| -4.7- | Validate disclaimer', () async {
      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');

      await driver.scrollUntilVisible(
          disclamerScrollable, endDisclamerScrollable,
          dyScroll: -5300);
      await driver.waitFor(checkEula);
      await driver.tap(checkEula);
      await driver.waitFor(checkTOC);
      await driver.tap(checkTOC);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(disclaimerNext);
      await driver.tap(disclaimerNext);

      expect(await driver.getText(createaPINScreen), 'Create PIN');
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('| -4.8- | Create PIN', () async {
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(find.text('Create PIN'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });

    test('| -4.9- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('| -4.10- | Check Markets-tab-nav-btn works', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');

      await driver.waitFor(markets);
      await driver.tap(markets);

      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');
    });

    test('| -4.11- | Check order-book-nav-btn works', () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(marketsOrderBookBtn);
      await driver.tap(marketsOrderBookBtn);

      expect(await driver.getText(marketsOrderBookEmptyScreen),
          'Please select coins');
    });

    test('| -4.12- | Check price-nav-btn works', () async {
      expect(await driver.getText(marketsOrderBookEmptyScreen),
          'Please select coins');

      await driver.waitFor(marketsPriceBtn);
      await driver.tap(marketsPriceBtn);

      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    });

    test(
        '| -4.13- | Check pressing on coin in price-screen moves you to order-book-screen and pops-up Select-Coin-Popup-Screen',
        () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(bitcoin);
      await driver.tap(bitcoin);

      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');
    });

    test(
        '| -4.14- | Check pressing on grey btn BTC/BTC in select-coin-pop-up does not do anything',
        () async {
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');

      await driver.waitFor(marketsCoinSelectBTC);
      await driver.tap(marketsCoinSelectBTC);

      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');
    });

    test(
        '| -4.15- | Check pressing on BTC/KMD in select-coin-pop-up brings up order-book-table',
        () async {
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');

      await driver.waitFor(marketsCoinSelectKMD);
      await driver.tap(marketsCoinSelectKMD);

      await driver.waitFor(marketsOrderBookTable);

      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');
    });

    // TODO(dth): enhancement - get values from both fields and make sure they ,indeed, swap.
    test('| -4.16- | Confirm coin-swap-btn works.', () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(marketsCoinSelectSwap);
      await driver.tap(marketsCoinSelectSwap);

      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');
    });

    test(
        '| -4.17- | Check coin-select-left button brings up select-coin-screen',
        () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(marketsCoinSelectLeft);
      await driver.tap(marketsCoinSelectLeft);

      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');
    });

    test(
        '| -4.18- | Confirm you can clear coin-select-left-btn field and order-book-table will dissapear',
        () async {
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');

      await driver.waitFor(marketsCoinSelectClear);
      await driver.tap(marketsCoinSelectClear);

      expect(await driver.getText(marketsOrderBookEmptyScreen),
          'Please select coins');
    });

    test(
        '| -4.19- | Confirm coin-select-right button brings up select-coin-screen',
        () async {
      expect(await driver.getText(marketsOrderBookEmptyScreen),
          'Please select coins');

      await driver.waitFor(marketsCoinSelectRight);
      await driver.tap(marketsCoinSelectRight);

      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');
    });

    test('| -4.20- | Confirm you can clear coin-select-right field', () async {
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');

      await driver.waitFor(marketsCoinSelectClear);
      await driver.tap(marketsCoinSelectClear);

      expect(await driver.getText(marketsOrderBookEmptyScreen),
          'Please select coins');
    });

    test('| -4.21- | Check FEED screen navigation works', () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(feed);
      await driver.tap(feed);

      expect(await driver.getText(feedScreen), 'NEWS FEED');
    });

    test('| -4.22- | Check SETTINGS screen navigation works', () async {
      expect(await driver.getText(feedScreen), 'NEWS FEED');

      await driver.waitFor(more);
      await driver.tap(more);

      await driver.waitFor(settings);
      await driver.tap(settings);

      expect(await driver.getText(settingsScreen), 'SETTINGS');
    });

    test('| -4.23- | Delete new wallet', () async {
      expect(await driver.getText(settingsScreen), 'SETTINGS');

      await driver.scrollUntilVisible(settingsScrollable, settingsDeleteWallet,
          dyScroll: -500);
      await driver.waitFor(settingsDeleteWallet);
      await driver.tap(settingsDeleteWallet);

      await driver.waitFor(enterPasswordField);
      await driver.tap(enterPasswordField);
      await driver.enterText(password);

      await driver.scrollIntoView(unlock);
      await driver.waitFor(unlock);
      await driver.tap(unlock);

      await driver.waitFor(delete);
      await driver.tap(delete);

      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
    });
  });
}
