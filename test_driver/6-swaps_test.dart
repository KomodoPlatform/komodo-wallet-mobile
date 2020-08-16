import 'dart:io';
import 'dart:math';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';


void main() {
  FlutterDriver driver;
  final rnd = Random();
  int globalDelay() => 500 + rnd.nextInt(500);

  final Map<String, String> envVars = Platform.environment;
  const password = '           a';

  //----------------------------- Scenario 6 Finders -----------------------------------------//   - 1 Restore Wallet Screen
  //              Scenario 6 is reserved for restoration of a wallet.                         //   - 2 Create Wallet Name Screen
  //----------(Scenario 6)---------- Restore Wallet ----------(Scenario 6)--------------------//   - 3 Enter Your Seed Screen
  final SerializableFinder createWalletScreen = find.text('CREATE A WALLET');                 //   - 4 Create Password Screen
  final SerializableFinder restoreWalletScreen = find.text('RESTORE');                        //   - 5 Accept Disclaimer Screen
  final SerializableFinder createWalletNameScreen = find.text('WELCOME');                     //   - 6 Create PIN Code Screen
  final SerializableFinder enterYourSeedScreen = find.text('Enter Your Seed Phrase');         //   - 7 Main Portfolio Screens
  final SerializableFinder createPasswordScreen = find.text('CREATE A PASSWORD');             //   - 8 Setting Screen (Delete Wallet)
  final SerializableFinder disclaimerScreen = find.text('Disclaimer & ToS');                  //
  final SerializableFinder createaPINScreen = find.text('Create PIN');                        //
  final SerializableFinder settingsScreen = find.byValueKey('settings-title');                //
  //------------------------------------------------------------------------------------------//
  /*-------------*/final SerializableFinder back = find.byTooltip('Back');/*------------------*/
  //---------------------- 1 - Restore wallet screen -----------------------------------------//
  final SerializableFinder restoreWalletBtn = find.byValueKey('restoreWallet');               //
  //---------------------- 2 - Create wallet name screen  ------------------------------------//
  final SerializableFinder welcomeScrollable = find.byValueKey('welcome-scrollable');         //
  final SerializableFinder nameWalletField = find.byValueKey('name-wallet-field');            //
  final SerializableFinder setup = find.text('LET\'S GET SET UP!');                           //
  //---------------------- 3 - Enter Your Seed Screen  ---------------------------------------//
  final SerializableFinder restoreSeedField = find.byValueKey('restore-seed-field');          //
  final SerializableFinder confirmSeedBtn = find.byValueKey('confirm-seed-button');           //
  //---------------------- 4 - Create password screen  ---------------------------------------//
  final SerializableFinder passwordCreate = find.byValueKey('create-password-field');         //
  final SerializableFinder passwordRetype = find.byValueKey('create-password-field-confirm'); //
  final SerializableFinder passwordConfirm = find.text('CONFIRM PASSWORD');                   //
  //---------------------- 5 - Accept disclaimer screen  -------------------------------------//
  final SerializableFinder disclamerScrollable = find.byValueKey('scroll-disclaimer');        //
  final SerializableFinder endDisclamerScrollable = find.byValueKey('end-list-disclaimer');   //
  final SerializableFinder checkEula = find.byValueKey('checkbox-eula');                      //
  final SerializableFinder checkTOC = find.byValueKey('checkbox-toc');                        //
  final SerializableFinder disclaimerNext = find.byValueKey('next-disclaimer');               //
  //---------------------- 6 - Create PIN screen ---------------------------------------------//
  //   Its better not to expect() Create/Confirm PIN code, driver gets confused.              //
  //---------------------- 7 - Main Portfolio Screens ----------------------------------------//
  final SerializableFinder bitcoin = find.text('BITCOIN');                                    //
  final SerializableFinder komodo = find.text('KOMODO');                                      //
    final SerializableFinder settings = find.byValueKey('side-nav-settings');                 //
  final SerializableFinder more = find.byValueKey('main-nav-more');                           //
  //---------------------- 8 - Setting Screen (Delete Wallet) --------------------------------//
  final SerializableFinder settingsScrollable = find.byValueKey('settings-scrollable');       //
  final SerializableFinder settingsDeleteWallet = find.text('Delete Wallet');                 //
  final SerializableFinder enterPasswordField = find.byValueKey('enter-password-field');      //
  final SerializableFinder unlock = find.byValueKey('unlock-wallet');                         //
  final SerializableFinder delete = find.byValueKey('delete-wallet');                         //
  //---------------------- 9 - Make Swaps ----------------------------------------------------//
  //final SerializableFinder portfolio = find.byValueKey('nav-portfolio');
  //final SerializableFinder portfolioCoinsScrollable = find.byValueKey('list-view-coins');
  final SerializableFinder loadingCoins = find.text('Loading coins');
  final SerializableFinder rickAdd = find.text('Morty (MORTY)');
  final SerializableFinder mortyAdd = find.text('Rick (RICK)');
  final SerializableFinder orderMatched = find.text('Order matched');
  final SerializableFinder step0outOf3 = find.byValueKey('Step 0/3');
  final SerializableFinder dex = find.byValueKey('main-nav-dex');
  final SerializableFinder morty = find.text('MORTY');
  final SerializableFinder rick = find.text('RICK');
  final SerializableFinder confirmDeactivateBtn = find.text('CONFIRM');
  final SerializableFinder coinDeactivateBtn = find.byValueKey('coin-deactivate');  
  //-----------------------------------END----------------------------------------------------//
  //---------------------------END-(Scenario-6)-END-------------------------------------------//
  //-----------------------------------END----------------------------------------------------//



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


  group('| (Scenario 6) Swaps  ', () {
    /*
    test('| -6.00- | (Delay: 60 seconds) Restore MORTY', () async {
      await Future<void>.delayed(const Duration(seconds: 60), () {});
    },timeout: const Timeout(Duration(seconds: 90)));
    */

    test('| -6.1- | Restore MORTY Wallet works (btn)', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('| -6.2- | Create MORTY Wallet name', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText('MORTY');
      await driver.waitFor(find.text('MORTY'));
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');
    });
    

    test('| -6.3- | Enter MORTY seed', () async {
      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');

      await driver.waitFor(restoreSeedField);
      await driver.tap(restoreSeedField);
      await driver.enterText(envVars['MORTY']);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(confirmSeedBtn);
      await driver.tap(confirmSeedBtn);

      expect(await driver.getText(createPasswordScreen),'CREATE A PASSWORD');
    });


    test('| -6.4- | Create MORTY password', () async {
      expect(await driver.getText(createPasswordScreen),'CREATE A PASSWORD');

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


    test('| -6.5- | Validate MORTY disclaimer', () async {
      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');

      await driver.scrollUntilVisible(disclamerScrollable, endDisclamerScrollable, dyScroll: -5300);
      await driver.waitFor(checkEula);
      await driver.tap(checkEula);
      await driver.waitFor(checkTOC);
      await driver.tap(checkTOC);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(disclaimerNext);
      await driver.tap(disclaimerNext);

      expect(await driver.getText(createaPINScreen), 'Create PIN');
    });


    test('| -6.6- | Create MORTY PIN ', () async {
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


    test('| -6.7- | (Delay: 5 seconds) Check if mm2 successfully connected', () async {
      await Future<void>.delayed(const Duration(seconds: 5), () {});
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('| -6.7- | Activate rick and morty coins', () async {

      await driver.waitFor(find.byValueKey('adding-coins'));
      await driver.tap(find.byValueKey('adding-coins'));

      await driver.scrollIntoView(mortyAdd);
      await driver.waitFor(mortyAdd);
      await driver.tap(mortyAdd);

      await driver.scrollIntoView(rickAdd);
      await driver.waitFor(rickAdd);
      await driver.tap(rickAdd);

      await driver.waitFor(find.byValueKey('done-activate-coins'));
      await driver.tap(find.byValueKey('done-activate-coins'));

      await driver.waitForAbsent(loadingCoins);

    });

    test('| -6.8- | Swap MORTY for RICK', () async{
      await driver.waitFor(dex);
      await driver.tap(dex);

      await driver.waitFor(find.byValueKey('coin-select-market.sell'));
      await driver.tap(find.byValueKey('coin-select-market.sell'));

      await driver.scrollIntoView(find.byValueKey('item-dialog-morty-market.sell'));
      await driver.waitFor(find.byValueKey('item-dialog-morty-market.sell'));
      await driver.tap(find.byValueKey('item-dialog-morty-market.sell'));

      await driver.scrollIntoView(find.byValueKey('input-text-market.sell'));
      await driver.waitFor(find.byValueKey('input-text-market.sell'));
      await driver.tap(find.byValueKey('input-text-market.sell'));
      await driver.enterText('1');

      await driver.waitFor(find.byValueKey('coin-select-market.receive'));
      await driver.tap(find.byValueKey('coin-select-market.receive'));

      await driver.scrollIntoView(find.byValueKey('orderbook-item-rick'));
      await driver.waitFor(find.byValueKey('orderbook-item-rick'));
      await driver.waitFor(find.byValueKey('orderbook-item-rick'));
      await driver.tap(find.byValueKey('orderbook-item-rick'));

      // pick-ask-order-number
      await driver.scrollIntoView(find.byValueKey('ask-item-0'));
      await driver.waitFor(find.byValueKey('ask-item-0'));
      await driver.tap(find.byValueKey('ask-item-0'));

      await driver.scrollIntoView(find.byValueKey('trade-button'));
      await driver.waitFor(find.byValueKey('trade-button'));
      await driver.tap(find.byValueKey('trade-button'));

      await driver.waitFor(find.byValueKey('confirm-swap-button'));
      await driver.scrollIntoView(find.byValueKey('confirm-swap-button'));
      await driver.tap(find.byValueKey('confirm-swap-button'));

      await driver.waitForAbsent(step0outOf3);
      expect(await driver.getText(orderMatched), 'Order matched');
      await driver.tap(find.byValueKey('swap-detail-back-button'));
    });


    test('| -6.9- | Delete MORTY wallet', () async {

      await driver.waitFor(more);
      await driver.tap(more);

      await driver.waitFor(settings);
      await driver.tap(settings);
      
      expect(await driver.getText(settingsScreen), 'SETTINGS');

      await driver.scrollUntilVisible(settingsScrollable,
          settingsDeleteWallet,
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
