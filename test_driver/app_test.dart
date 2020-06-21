import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';


/*
    Because of the issue that was uncovered here https://github.com/ca333/komodoDEX/issues/732
    TL;DR - mm2 refuses to launch alongside flutter_driver on the same run.
    Until this is fixed we have to run tests the following way:
    1. flutter run -t test_driver/app.dart
    2. flutter drive --target=test_driver/app.dart --use-existing-app=http://127.0.0.1:64543/N3XhhddWVME=/
    In order to test swaps and send/receive I used the following seeds as env variables:
    export RICK='offer venue embark tank eyebrow grape great era nothing top unveil pear'
    export MORTY='pear enforce exit dial spell draft chief lobster cabin refuse swift scan'
    PIN: 0000
    password: '           a'  (11 spaces + 'a')
*/

void main() {
  FlutterDriver driver;
  
  // Variables
  final Map<String, String> envVars = Platform.environment;
  var seed = ['a', 'b'];
  var mortysRickAddress = '';
  var ricksMortyAddress = '';
  var sendAmount = '0.1';
  var password = 'aaa333%1AKl@';
  var postRefreshSeed = '';
  bool isAndroid = false;

  // Text
  final SerializableFinder titleWelcome = find.text('WELCOME');
  final SerializableFinder seedPhrase = find.byValueKey('seed-phrase');
  final SerializableFinder rickAdd = find.text('Morty (MORTY)');
  final SerializableFinder mortyAdd = find.text('Rick (RICK)');
  final SerializableFinder morty = find.text('MORTY');
  final SerializableFinder rick = find.text('RICK');
  final SerializableFinder address = find.byValueKey('coin-details-address');
  final SerializableFinder successSend = find.text('Success!');
  final SerializableFinder whichWordText = find.byValueKey('which-word');
  final SerializableFinder connecting = find.text('Connecting...');
  final SerializableFinder loadingCoins = find.text('Loading coins');

  // Buttons
  final SerializableFinder createWallet = find.text('CREATE A WALLET');
  final SerializableFinder restoreWallet = find.text('RESTORE');
  final SerializableFinder setup = find.text('LET\'S GET SET UP!');
  final SerializableFinder welcomeSetup = find.byValueKey('welcome-setup');
  final SerializableFinder seedRefresh = find.byValueKey('seed-refresh');
  final SerializableFinder seedCopy = find.byValueKey('seed-copy');
  final SerializableFinder next = find.text('NEXT');
  final SerializableFinder receive = find.text('RECEIVE');
  final SerializableFinder close = find.text('CLOSE');
  final SerializableFinder back = find.byTooltip('Back');
  final SerializableFinder switchTile = find.text('Activate PIN protection');
  final SerializableFinder switchPin = find.byValueKey('settings-activate-pin');
  final SerializableFinder logout = find.byValueKey('settings-pin-logout');
  final SerializableFinder send = find.byValueKey('secondary-button-send');
  final SerializableFinder cancel = find.byValueKey('secondary-button-cancel');
  final SerializableFinder withdraw = find.byValueKey('primary-button-withdraw');
  final SerializableFinder confirm = find.byValueKey('primary-button-confirm');
  final SerializableFinder customFee = find.byValueKey('send-toggle-customfee');
  final SerializableFinder settings = find.byValueKey('nav-settings');
  final SerializableFinder portfolio = find.byValueKey('nav-portfolio');
  final SerializableFinder dex = find.byValueKey('nav-dex');
  final SerializableFinder news = find.byValueKey('nav-news');
  final SerializableFinder login = find.text('LOGIN');
  final SerializableFinder pasteIOS = find.text('Paste');
  final SerializableFinder pasteAndroid = find.text('PASTE');
  final SerializableFinder continueSeedVerification = find.text('CONTINUE');
  final SerializableFinder confirmPassword = find.byValueKey('confirm-password');

  // Scrollables
  final SerializableFinder settingsScrollable = find.byValueKey('settings-scrollable');
  final SerializableFinder welcomeScrollable = find.byValueKey('welcome-scrollable');
  final SerializableFinder newAccountScrollable = find.byValueKey('new-account-scrollable');
  final SerializableFinder disclamerScrollable = find.byValueKey('scroll-disclaimer');

  // Input fields
  final SerializableFinder nameWalletField = find.byValueKey('name-wallet-field');
  final SerializableFinder enterPasswordField = find.byValueKey('enter-password-field');
  final SerializableFinder passwordCreate = find.byValueKey('create-password-field');
  final SerializableFinder passwordConfirm = find.byValueKey('create-password-field-confirm');
  final SerializableFinder amountField = find.byValueKey('send-amount-field');
  final SerializableFinder recipientsAddress = find.byValueKey('send-address-field');
  final SerializableFinder whichWordField = find.byValueKey('which-word-field');



  setUpAll(() async {
    driver = await FlutterDriver.connect();
    final String platform = await driver.requestData('platform');
    if (platform == 'android') isAndroid = true;
  });


  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });


  group('Driver Health |', () {
    test('Print flutter driver health', () async {
      final Health health = await driver.checkHealth();
      print(health.status);
    });
  });


  group('Create new wallet |', () {
    test('Create wallet name', () async {
      expect(await driver.getText(createWallet), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.tap(createWallet);
      expect(await driver.getText(titleWelcome), 'WELCOME');
      await driver.tap(nameWalletField);
      await driver.enterText('testNewWallet');
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.tap(setup);
    });


    test('Check seed refresh', () async {
      var initialSeed = '';
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(seedPhrase);
      await driver.getText(seedPhrase).then((val) {
        initialSeed = val;
      });
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.tap(seedRefresh);
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.getText(seedPhrase).then((val) {
        postRefreshSeed = val;
      });
      if (initialSeed == postRefreshSeed){
        await driver.waitFor(find.text('NONE EXISTENT TEXT TO FAIL THE TEST'),
                              timeout: const Duration(seconds: 3));
      }
    });


    test('Check if seed copy works', () async {
      final pasteFinder = isAndroid ? pasteAndroid : pasteIOS;

      await driver.tap(seedCopy);
      await driver.scrollUntilVisible(newAccountScrollable, next, dyScroll: -300);
      await driver.tap(next); 
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      await driver.waitFor(whichWordField);
      await driver.tap(whichWordField);
      await driver.scroll(whichWordField, 0, 0, const Duration(milliseconds: 1100));
      await driver.waitFor(pasteFinder);
      await driver.tap(pasteFinder);
      await driver.waitFor(find.text(postRefreshSeed));
      /*await driver.getText(whichWordField).then((val) {
        print(val);
        if (postRefreshSeed != val){
          driver.waitFor(find.text('NONE EXISTENT TEXT TO FAIL THE TEST'),
                              timeout: const Duration(seconds: 1));
      }});*/
      await driver.tap(back);
    });
    

    test('Save seed', () async {
      await driver.waitFor(seedPhrase);
      await driver.getText(seedPhrase).then((val) {
        seed = val.split(' ');
      });
    });


    test('Verify seed', () async {
      int whichWord;
      await driver.scrollUntilVisible(newAccountScrollable, next, dyScroll: -300);
      await driver.tap(next);
      for (int i = 0; i <= 2; i++){
        await driver.waitFor(whichWordText);
        await driver.getText(whichWordText).then((val) {
          whichWord = int.tryParse(val.split(' ')[3].replaceAll(RegExp(r'[^\w\s]+'),''))  - 1;
        });
        await driver.tap(whichWordField);
        await driver.enterText(seed[whichWord]);
        await Future<void>.delayed(const Duration(milliseconds: 500), () {});
        await driver.scrollIntoView(continueSeedVerification);
        await driver.waitFor(continueSeedVerification);
        await driver.tap(continueSeedVerification);
      }
    });
    

    test('Create password', () async {
      expect(await driver.getText(find.text('CREATE A PASSWORD')),
          'CREATE A PASSWORD');
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await driver.waitFor(find.text(password));
      await driver.tap(passwordConfirm);
      await driver.enterText(password);
      await driver.waitFor(find.text(password));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.text('CONFIRM PASSWORD'));
    });


    test('Validate disclaimer', () async {
      await driver.waitFor(find.text('Disclaimer & ToS'));
      await driver.scrollUntilVisible(disclamerScrollable,
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5000);
      await driver.tap(find.byValueKey('checkbox-eula'));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('next-disclaimer'));
    });


    test('Create PIN', () async {
      await driver.waitFor(find.text('Create PIN'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });


    test('Check if mm2 successfully connected', () async {
      await driver.waitForAbsent(connecting);
      await driver.waitForAbsent(loadingCoins);
    }, timeout: const Timeout(Duration(minutes: 2)));


    test('Logout from new wallet', () async {
      await driver.tap(settings);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.scrollUntilVisible(settingsScrollable,
                                      switchTile,
                                      dyScroll: -300);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(switchPin);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(logout);
    });
  });


  group('Test send/receive |', () {
    test('Restore morty wallet', () async {
      expect(await driver.getText(createWallet), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.tap(restoreWallet);
      expect(await driver.getText(titleWelcome), 'WELCOME');
      await driver.tap(nameWalletField);
      await driver.enterText('MORTY');
      await driver.waitFor(find.text('MORTY'));
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);
    });
    

    test('Restore morty seed', () async {
      await driver.tap(find.byValueKey('restore-seed-field'));
      await driver.enterText(envVars['MORTY']);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('confirm-seed-button'));
    });


    test('Create morty password', () async {
      expect(await driver.getText(find.text('CREATE A PASSWORD')),
          'CREATE A PASSWORD');
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await driver.waitFor(find.text(password));
      await driver.tap(passwordConfirm);
      await driver.enterText(password);
      await driver.waitFor(find.text(password));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.text('CONFIRM PASSWORD'));
    });


    test('Validate morty disclaimer', () async {
      await driver.waitFor(find.text('Disclaimer & ToS'));
      await driver.scrollUntilVisible(find.byValueKey('scroll-disclaimer'),
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5000);
      await driver.tap(find.byValueKey('checkbox-eula'));
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('next-disclaimer'));
    });


    test('Create morty PIN', () async {
      await driver.waitFor(find.text('Create PIN'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });


    test('Check if mm2 successfully connected', () async {
      await driver.waitForAbsent(connecting);
      await driver.waitForAbsent(loadingCoins);
    }, timeout: const Timeout(Duration(minutes: 2)));


    test('Activate rick and morty addresses', () async {
      await driver.tap(find.byValueKey('adding-coins'));
      await driver.scrollIntoView(mortyAdd);
      await driver.tap(mortyAdd);
      await driver.scrollIntoView(rickAdd);
      await driver.tap(rickAdd);
      await driver.tap(find.byValueKey('done-activate-coins'));
      await driver.waitForAbsent(loadingCoins);
    });


    test('Get rick address', () async {
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.scrollIntoView(rick);
      await driver.tap(rick);
      await driver.runUnsynchronized(() async {
      await driver.waitFor(receive);
      await driver.tap(receive);
      await driver.waitFor(address);
      await driver.getText(address).then((val) {
        mortysRickAddress = val;
      });
      await driver.tap(close);
      await driver.tap(back);
    });});


    test('Logout from morty wallet', () async {
      await driver.tap(settings);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.scrollUntilVisible(settingsScrollable,
                                      switchTile,
                                      dyScroll: -300);
      await driver.tap(switchPin);
      await driver.tap(logout);
    });


    test('Restore rick wallet', () async {
      expect(await driver.getText(createWallet), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.tap(restoreWallet);
      expect(await driver.getText(titleWelcome), 'WELCOME');
      await driver.tap(nameWalletField);
      await driver.enterText('RICK');
      await driver.waitFor(find.text('RICK'));
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.tap(setup);
    });
    

    test('Restore rick seed', () async {
      await driver.tap(find.byValueKey('restore-seed-field'));
      await driver.enterText(envVars['RICK']);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('confirm-seed-button'));
    });


    test('Create rick password', () async {
      expect(await driver.getText(find.text('CREATE A PASSWORD')),
          'CREATE A PASSWORD');
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await driver.waitFor(find.text(password));
      await driver.tap(passwordConfirm);
      await driver.enterText(password);
      await driver.waitFor(find.text(password));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.text('CONFIRM PASSWORD'));
    });


    test('Validate rick disclaimer', () async {
      await driver.waitFor(find.text('Disclaimer & ToS'));
      await driver.scrollUntilVisible(find.byValueKey('scroll-disclaimer'),
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5000);
      await driver.tap(find.byValueKey('checkbox-eula'));
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(find.byValueKey('next-disclaimer'));
    });


    test('Create rick PIN', () async {
      await driver.waitFor(find.text('Create PIN'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });


    test('Check if mm2 successfully connected', () async {
      await driver.waitForAbsent(connecting);
      await driver.waitForAbsent(loadingCoins);
    }, timeout: const Timeout(Duration(minutes: 2)));


    test('Get morty address', () async {
      await driver.scrollIntoView(morty);
      await driver.tap(morty);
      await driver.runUnsynchronized(() async {
      await driver.waitFor(receive);
      await driver.tap(receive);
      await driver.waitFor(address);
      await driver.getText(address).then((val) {
        ricksMortyAddress = val;
      });
      await driver.tap(close);
      await driver.tap(back);
    });});
    

    test('Send RICK from rick to morty', () async {
      await driver.scrollIntoView(rick);
      await driver.tap(rick);
      await driver.runUnsynchronized(() async {
      await driver.waitFor(send);
      await driver.tap(send);
      await driver.waitFor(amountField);
      await driver.tap(amountField);
      await driver.enterText(sendAmount);
      await driver.tap(recipientsAddress);
      await driver.enterText(mortysRickAddress);
      await driver.tap(withdraw);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.waitFor(confirm);
      await driver.tap(confirm);
      await driver.waitFor(successSend);
      await driver.waitForAbsent(successSend);
      await driver.tap(back);
    });});


    test('Logout from rick wallet', () async {
      await driver.tap(settings);
      await driver.scrollUntilVisible(settingsScrollable,
                                      switchTile,
                                      dyScroll: -300);
      await driver.tap(switchPin);
      await driver.tap(logout);
    });


    test('Login to morty', () async {
      await driver.scrollIntoView(morty);
      await driver.tap(morty);
      await driver.tap(enterPasswordField);
      await driver.enterText(password);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.scrollIntoView(login);
      await driver.tap(login);
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });


    test('Check if mm2 successfully connected', () async {
      await driver.waitForAbsent(connecting);
      await driver.waitForAbsent(loadingCoins);
    }, timeout: const Timeout(Duration(minutes: 2)));


    test('Check RICK transfer confirmed', () async {
      await driver.scrollIntoView(rick);
      await driver.tap(rick);
      await driver.runUnsynchronized(() async {
      await driver.waitFor(find.text('+$sendAmount RICK'),
                           timeout: const Duration(minutes: 1));
      await driver.tap(back);
    });});


    test('Send MORTY from morty to rick', () async {
      await driver.scrollIntoView(morty);
      await driver.tap(morty);
      await driver.runUnsynchronized(() async {
      await driver.waitFor(send);
      await driver.tap(send);
      await driver.waitFor(amountField);
      await driver.tap(amountField);
      await driver.enterText(sendAmount);
      await driver.tap(recipientsAddress);
      await driver.enterText(ricksMortyAddress);
      await driver.tap(withdraw);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.waitFor(confirm);
      await driver.tap(confirm);
      await driver.waitFor(successSend);
      await driver.waitForAbsent(successSend);
      await driver.tap(back);
    });});


    test('Logout from morty wallet', () async {
      await driver.tap(settings);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.scrollUntilVisible(settingsScrollable,
                                      switchTile,
                                      dyScroll: -300);
      await driver.tap(switchPin);
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
      await driver.tap(switchPin);
      await driver.tap(logout);
    });


    test('Login to rick', () async {
      await driver.scrollIntoView(rick);
      await driver.tap(rick);
      await driver.tap(enterPasswordField);
      await driver.enterText(password);
      await driver.scrollIntoView(login);
      await driver.tap(login);
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });


    test('Check if mm2 successfully connected', () async {
      await driver.waitForAbsent(connecting);
      await driver.waitForAbsent(loadingCoins);
    }, timeout: const Timeout(Duration(minutes: 2)));


    test('Check MORTY transfer confirmed', () async {
      await driver.scrollIntoView(morty);
      await driver.tap(morty);
      await driver.runUnsynchronized(() async {
      await driver.waitFor(find.text('+$sendAmount MORTY'),
                           timeout: const Duration(minutes: 1));
      await driver.tap(back);
    });});
  });



    

 
/*
  group('Restore wallet', () {
    test('Name Wallet', () async {
      final SerializableFinder createWallet = find.text('CREATE A WALLET');
      final SerializableFinder restoreWallet = find.text('RESTORE');
      final SerializableFinder titleWelcome = find.text('WELCOME');
      expect(await driver.getText(createWallet), 'CREATE A WALLET');
      expect(await driver.getText(restoreWallet), 'RESTORE');
      await driver.tap(restoreWallet);
      expect(await driver.getText(titleWelcome), 'WELCOME');
      final SerializableFinder nameWalletField =
          find.byValueKey('name-wallet-field');
      await driver.tap(nameWalletField);
      await driver.enterText('Mon super wallet');
      await driver.waitFor(find.text('Mon super wallet'));
      await driver.tap(setup);
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
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
      await driver.waitFor(find.text('Confirm PIN code'));
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });
    test('Check if default coins are here', () async {
      await driver.waitFor(find.text('KOMODO'));
      await driver.waitFor(find.text('BITCOIN'));
    });
  });
  group('Activate coins |', () {
    test('Activates all coins', () async {
      await driver.tap(find.byValueKey('adding-coins'));
      final SerializableFinder SelectUTXO = find.text('Select all UTXO coins');
      final SerializableFinder SelectSmartchains = find.text('Select all SmartChains');
      final SerializableFinder SelectERC = find.text('Select all ERC tokens');
      await driver.tap(SelectUTXO);
      await driver.scrollIntoView(SelectSmartchains);
      await driver.tap(SelectSmartchains);
      await driver.scrollIntoView(SelectERC);
      await driver.tap(SelectERC);
      await driver.tap(find.byValueKey('done-activate-coins'));
    });
  });
  //deactivated until we find a better way to deal with swap-tests
  group('Make Swaps |', (){
    test('Swap MORTY for RICK', () async{
      await driver.tap(find.byValueKey('icon-swap-page'));
      await driver.waitFor(find.byValueKey('exchange-title'));
      await driver.tap(find.byValueKey('coin-select-market.sell'));
      await driver.waitFor(find.byValueKey('item-dialog-morty-market.sell'));
      await driver.scrollIntoView(find.byValueKey('item-dialog-morty-market.sell'));
      await driver.tap(find.byValueKey('item-dialog-morty-market.sell'));
      await driver.tap(find.byValueKey('input-text-market.sell'));
      await driver.enterText('0,02');
      await driver.tap(find.byValueKey('coin-select-market.receive'));
      await driver.scrollUntilVisible(find.byValueKey('receive-list-coins'),
          find.byValueKey('orderbook-item-rick'),
          dyScroll: -300);
      await driver.scrollIntoView(find.byValueKey('orderbook-item-rick'));
      await driver.waitFor(find.byValueKey('orderbook-item-rick'));
      await driver.tap(find.byValueKey('orderbook-item-rick'));
      await driver.tap(find.byValueKey('ask-item-0'));
      await driver.waitFor(find.byValueKey('exchange-title'));
      await driver.tap(find.byValueKey('trade-button'));
      await driver.waitFor(find.byValueKey('swap-detail-title'));
      
      await driver.tap(find.byValueKey('confirm-swap-button'));
      await driver.waitFor(find.text('Order matched'));
      await driver.waitFor(find.text('Swap successful'),
                           timeout: const Duration(minutes: 10));
      await driver.tap(find.byValueKey('swap-detail-back-button'));
    }, timeout: Timeout.none);
  });
  
  group('Settings', () {
    test('Send feedback', () async {
      await driver.tap(find.byValueKey('nav-settings'));
      await driver.scrollUntilVisible(find.byValueKey('settings-scrollable'),
          find.byValueKey('setting-title-feedback'),
          dyScroll: -300);
      await driver.tap(find.byValueKey('setting-title-feedback'));
      await driver.tap(find.byValueKey('setting-share-button'));
    });
  });
*/
}
