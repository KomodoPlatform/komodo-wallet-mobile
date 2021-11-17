// ignore_for_file: file_names

import 'dart:io';
import 'dart:math';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;
  final rnd = Random();
  final Map<String, String> envVars = Platform.environment;

  var mortysRickAddress = '';
  var ricksMortyAddress = '';
  const String sendAmount = '0.1'; // TODO(dth): make rnd.nextFloat
  const password = '           a';
  int globalDelay() => 700 + rnd.nextInt(500);
  bool isAndroid = false;
  int coolOffTime = 60;

  //----------------------------- Scenario 5 Finders -----------------------------------------//   - 1 Restore Wallet Screen
  //              Scenario 5 is reserved for restoration of a wallet.                         //   - 2 Create Wallet Name Screen
  //----------(Scenario 5)---------- Restore Wallet ----------(Scenario 5)--------------------//   - 3 Enter Your Seed Screen
  //         !!!!----- Mostly the same Finders as per Scenario 1 ------!!!!!                  //   - 4 Create Password Screen
  final SerializableFinder createWalletScreen = find.text('CREATE A WALLET'); //
  final SerializableFinder restoreWalletScreen =
      find.text('RESTORE'); //   - 5 Accept Disclaimer Screen
  final SerializableFinder createWalletNameScreen =
      find.text('WELCOME'); //   - 6 Create PIN Code Screen
  final SerializableFinder enterYourSeedScreen =
      find.text('Enter Your Seed Phrase'); //   - 7 Main Portfolio Screens
  final SerializableFinder createPasswordScreen =
      find.text('CREATE A PASSWORD'); //   - 8 Setting Screen (Delete Wallet)
  final SerializableFinder disclaimerScreen = find.text('Disclaimer & ToS'); //
  final SerializableFinder createaPINScreen = find.text('Create PIN'); //
  final SerializableFinder settingsScreen =
      find.byValueKey('settings-title'); //
  //------------------------------------------------------------------------------------------//
  /*-------------*/ final SerializableFinder back =
      find.byTooltip('Back'); /*------------------*/
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
  //---------------------- 6 - Create PIN screen ---------------------------------------------//
  //   Its better not to expect() Create/Confirm PIN code, driver gets confused.              //
  //---------------------- 7 - Main Portfolio Screens ----------------------------------------//
  final SerializableFinder settings = find.byValueKey('side-nav-settings'); //
  final SerializableFinder more = find.byValueKey('main-nav-more'); //
  final SerializableFinder bitcoin = find.text('BITCOIN'); //
  final SerializableFinder komodo = find.text('KOMODO'); //
  //---------------------- 8 - Setting Screen (Delete Wallet) --------------------------------//
  final SerializableFinder settingsScrollable =
      find.byValueKey('settings-scrollable'); //
  final SerializableFinder enterPasswordField =
      find.byValueKey('enter-password-field'); //
  //----------------------------------------END-----------------------------------------------//
  //---------------------------END-(Scenario-5-Finders)-END-----------------------------------//
  //----------------------------------------END-----------------------------------------------//

  //-------------------------- Scenario 4 Finders --------------------------------------------//
  //           Scenario 4 is reserved for testing send/receive and swaps.                     //
  //-----(Scenario 4)------- Test send/receive and swaps -------(Scenario 4)------------------//
  //final SerializableFinder portfolio = find.byValueKey('nav-portfolio');
  //final SerializableFinder portfolioCoinsScrollable = find.byValueKey('list-view-coins');
  final SerializableFinder loadingCoins = find.text('Loading coins');
  final SerializableFinder rickAdd = find.text('Morty (MORTY)');
  final SerializableFinder mortyAdd = find.text('Rick (RICK)');
  final SerializableFinder morty = find.text('MORTY');
  final SerializableFinder rick = find.text('RICK');
  final SerializableFinder confirmDeactivateBtn = find.text('CONFIRM');
  final SerializableFinder coinDeactivateBtn =
      find.byValueKey('coin-deactivate');

  final SerializableFinder login = find.text('LOGIN');
  //---------------------- 8 - Setting Screen (Delete Wallet) --------------------------------//
  final SerializableFinder settingsDeleteWallet = find.text('Delete Wallet'); //
  final SerializableFinder unlock = find.byValueKey('unlock-wallet'); //
  final SerializableFinder delete = find.byValueKey('delete-wallet'); //

  final SerializableFinder amountField = find.byValueKey('send-amount-field');
  final SerializableFinder recipientsAddress =
      find.byValueKey('send-address-field');
  final SerializableFinder successSend = find.text('Success!');
  final SerializableFinder address = find.byValueKey('coin-details-address');
  final SerializableFinder receive = find.text('RECEIVE');
  final SerializableFinder close = find.text('CLOSE');
  final SerializableFinder send = find.byValueKey('secondary-button-send');
  //final SerializableFinder cancel = find.byValueKey('secondary-button-cancel');
  final SerializableFinder withdraw =
      find.byValueKey('primary-button-withdraw');
  final SerializableFinder confirm = find.byValueKey('primary-button-confirm');
  //final SerializableFinder customFee = find.byValueKey('send-toggle-customfee');
  final SerializableFinder logout = find.byValueKey('side-nav-logout');
  final SerializableFinder logoutYes = find.byValueKey('settings-logout-yes');
  //-----------------------------------END----------------------------------------------------//
  //---------------------------END-(Scenario-5)-END-------------------------------------------//
  //-----------------------------------END----------------------------------------------------//

  setUpAll(() async {
    driver = await FlutterDriver.connect();
    final String platform = await driver.requestData('platform');
    if (platform == 'android') isAndroid = true;
    if (isAndroid) coolOffTime = 1;
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

  group('| (Scenario 5) Send/Receive  ', () {
    test('| -5.1- | Restore MORTY Wallet', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });

    test('| -5.2- | Create MORTY Wallet name', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText('MORTY');
      await driver.waitFor(find.text('MORTY'));
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(
          await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');
    });

    test('| -5.3- | Enter MORTY seed', () async {
      expect(
          await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');

      await driver.waitFor(restoreSeedField);
      await driver.tap(restoreSeedField);
      await driver.enterText(envVars['MORTY']);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(confirmSeedBtn);
      await driver.tap(confirmSeedBtn);

      expect(await driver.getText(createPasswordScreen), 'CREATE A PASSWORD');
    });

    test('| -5.4- | Create MORTY password', () async {
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

    test('| -5.5- | Validate MORTY disclaimer', () async {
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
    });

    test('| -5.6- | Create MORTY PIN ', () async {
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

    test('| -5.7- | (Delay: 5 seconds) Check if mm2 successfully connected ',
        () async {
      await Future<void>.delayed(const Duration(seconds: 5), () {});
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('| -5.8- | Activate rick and morty coins', () async {
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

    test('| -5.9- | Get mortysRickAddress', () async {
      await driver.scrollIntoView(rick);
      await driver.waitFor(rick);
      await driver.tap(rick);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(receive);
        await driver.tap(receive);

        await driver.waitFor(address);
        await driver.getText(address).then((val) {
          mortysRickAddress = val;
        });
        await driver.waitFor(close);
        await driver.tap(close);

        await driver.waitFor(back);
        await driver.tap(back);
      });
    });

    test('| -5.10- | Deactivate rick and morty coins', () async {
      await driver.scrollIntoView(rick);
      await driver.waitFor(rick);
      await driver.tap(rick);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(coinDeactivateBtn);
        await driver.tap(coinDeactivateBtn);
        await driver.waitFor(confirmDeactivateBtn);
        await driver.tap(confirmDeactivateBtn);
      });

      await driver.scrollIntoView(morty);
      await driver.waitFor(morty);
      await driver.tap(morty);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(coinDeactivateBtn);
        await driver.tap(coinDeactivateBtn);
        await driver.waitFor(confirmDeactivateBtn);
        await driver.tap(confirmDeactivateBtn);
      });
    });

    test('| -5.11- | Logout from MORTY wallet', () async {
      await driver.waitFor(more);
      await driver.tap(more);
      await driver.waitFor(logout);
      await driver.tap(logout);
      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    });

    // RELOG-1

    test('| -5.12- | (Delay: $coolOffTime seconds) Relog to RICK', () async {
      await Future<void>.delayed(Duration(seconds: coolOffTime), () {});
    }, timeout: Timeout(Duration(seconds: coolOffTime + 30)));

    test('| -5.13- | Restore RICK wallet', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletScreen);
      await driver.tap(restoreWalletScreen);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText('RICK');
      await driver.waitFor(find.text('RICK'));
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(
          await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');
    });

    test('| -5.14- | Restore RICK seed', () async {
      expect(
          await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');

      await driver.waitFor(restoreSeedField);
      await driver.tap(restoreSeedField);
      await driver.enterText(envVars['RICK']);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(confirmSeedBtn);
      await driver.tap(confirmSeedBtn);
    });

    test('| -5.15- | Create RICK password', () async {
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

    test('| -5.16- | Validate RICK disclaimer', () async {
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
    });

    test('| -5.17- | Create RICK PIN ', () async {
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

    test('| -5.18- | (Delay: 5 seconds) Check if mm2 successfully connected ',
        () async {
      await Future<void>.delayed(const Duration(seconds: 5), () {});
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('| -5.19- | Activate rick and morty coins', () async {
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

    test('| -5.20- | (Delay: 5 seconds) Get ricksMortyAddress', () async {
      await Future<void>.delayed(const Duration(seconds: 5), () {});
      await driver.scrollIntoView(morty);
      await driver.waitFor(morty);
      await driver.tap(morty);
      await driver.runUnsynchronized(() async {
        await driver.waitFor(receive);
        await driver.tap(receive);
        await driver.waitFor(address);
        await driver.getText(address).then((val) {
          ricksMortyAddress = val;
        });
        await driver.waitFor(close);
        await driver.tap(close);
        await driver.waitFor(back);
        await driver.tap(back);
      });
    });

    test('| -5.21- | Send RICK from rick to morty', () async {
      await driver.waitFor(rick);
      await driver.tap(rick);

      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(send);
        await driver.tap(send);

        await driver.waitFor(amountField);
        await driver.tap(amountField);

        await driver.enterText(sendAmount);
        await driver.waitFor(recipientsAddress);
        await driver.tap(recipientsAddress);

        await driver.enterText(mortysRickAddress);
        await driver.waitFor(withdraw);
        await driver.tap(withdraw);
        await Future<void>.delayed(
            Duration(milliseconds: globalDelay()), () {});
        await driver.waitFor(confirm);
        await driver.tap(confirm);

        await driver.waitFor(successSend);
        await driver.waitForAbsent(successSend);
        print('from rick $ricksMortyAddress to morty $mortysRickAddress');
        await driver.waitFor(back);
        await driver.tap(back);
      });
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('| -5.22- | Deactivate rick and morty coins', () async {
      await driver.scrollIntoView(rick);
      await driver.waitFor(rick);
      await driver.tap(rick);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(coinDeactivateBtn);
        await driver.tap(coinDeactivateBtn);
        await driver.waitFor(confirmDeactivateBtn);
        await driver.tap(confirmDeactivateBtn);
      });

      await driver.scrollIntoView(morty);
      await driver.waitFor(morty);
      await driver.tap(morty);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(coinDeactivateBtn);
        await driver.tap(coinDeactivateBtn);
        await driver.waitFor(confirmDeactivateBtn);
        await driver.tap(confirmDeactivateBtn);
      });
    });

    test('| -5.23- | Logout from RICK wallet', () async {
      await driver.waitFor(more);
      await driver.tap(more);
      await driver.waitFor(logout);
      await driver.tap(logout);
      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    });

    test('| -5.24- | (Delay: $coolOffTime seconds) Relog to MORTY', () async {
      await Future<void>.delayed(Duration(seconds: coolOffTime), () {});
    }, timeout: Timeout(Duration(seconds: coolOffTime + 30)));

    // RELOG-2
    test('| -5.25- | Login to MORTY wallet', () async {
      await driver.tap(morty);

      await driver.tap(enterPasswordField);
      await driver.enterText(password);

      await driver.scrollIntoView(login);
      await driver.tap(login);
    });

    test('| -5.26- | (Delay: 5 seconds) Check if mm2 successfully connected ',
        () async {
      await Future<void>.delayed(const Duration(seconds: 5), () {});
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('| -5.27- | Activate rick and morty coins', () async {
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

    test('| -5.28- | (Delay: 5 seconds) Check RICK transfer confirmed',
        () async {
      await Future<void>.delayed(const Duration(seconds: 5), () {});
      await driver.tap(rick);
      await driver.runUnsynchronized(() async {
        await driver.waitFor(find.text('+$sendAmount RICK'));
        await driver.waitFor(back);
        await driver.tap(back);
      });
    });

    test('| -5.29- | Send MORTY from morty to rick', () async {
      await driver.tap(morty);

      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(send);
        await driver.tap(send);

        await driver.waitFor(amountField);
        await driver.tap(amountField);
        await driver.enterText(sendAmount);

        await driver.waitFor(recipientsAddress);
        await driver.tap(recipientsAddress);
        await driver.enterText(ricksMortyAddress);

        await driver.waitFor(withdraw);
        await driver.tap(withdraw);
        await Future<void>.delayed(
            Duration(milliseconds: globalDelay()), () {});
        await driver.waitFor(confirm);
        await driver.tap(confirm);

        await driver.waitFor(successSend);
        await driver.waitForAbsent(successSend);
        print('from morty $mortysRickAddress to rick $ricksMortyAddress');
        await driver.waitFor(back);
        await driver.tap(back);
      });
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('| -5.30- | Deactivate rick and morty coins', () async {
      await driver.scrollIntoView(rick);
      await driver.waitFor(rick);
      await driver.tap(rick);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(coinDeactivateBtn);
        await driver.tap(coinDeactivateBtn);
        await driver.waitFor(confirmDeactivateBtn);
        await driver.tap(confirmDeactivateBtn);
      });

      await driver.scrollIntoView(morty);
      await driver.waitFor(morty);
      await driver.tap(morty);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(coinDeactivateBtn);
        await driver.tap(coinDeactivateBtn);
        await driver.waitFor(confirmDeactivateBtn);
        await driver.tap(confirmDeactivateBtn);
      });
    });

    test('| -5.31- | Delete MORTY wallet', () async {
      await driver.waitFor(more);
      await driver.tap(more);

      await driver.waitFor(settings);
      await driver.tap(settings);
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

    test('| -5.32- | (Delay: $coolOffTime seconds) Relog to RICK', () async {
      await Future<void>.delayed(Duration(seconds: coolOffTime), () {});
    }, timeout: Timeout(Duration(seconds: coolOffTime + 30)));

    // RELOG-3
    test('| -5.33- | LOGIN to RICK wallet ', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');

      await driver.tap(rick);

      await driver.tap(enterPasswordField);
      await driver.enterText(password);

      await driver.scrollIntoView(login);
      await driver.tap(login);
    });

    test('| -5.34- | (Delay: 5 seconds) Check if mm2 successfully connected ',
        () async {
      await Future<void>.delayed(const Duration(seconds: 5), () {});
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));

    test('| -5.35- | Activate rick and morty coins', () async {
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

    test('| -5.36- | (Delay: 5 seconds) Check transfer from MORTY confirmed',
        () async {
      await Future<void>.delayed(const Duration(seconds: 5), () {});
      await driver.scrollIntoView(morty);
      await driver.tap(morty);

      await driver.runUnsynchronized(() async {
        await driver.waitFor(find.text('+$sendAmount MORTY'));

        await driver.waitFor(back);
        await driver.tap(back);
      });
    });

    test('| -5.37- | Deactivate rick and morty coins', () async {
      await driver.scrollIntoView(rick);
      await driver.waitFor(rick);
      await driver.tap(rick);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(coinDeactivateBtn);
        await driver.tap(coinDeactivateBtn);
        await driver.waitFor(confirmDeactivateBtn);
        await driver.tap(confirmDeactivateBtn);
      });

      await driver.scrollIntoView(morty);
      await driver.waitFor(morty);
      await driver.tap(morty);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.runUnsynchronized(() async {
        await driver.waitFor(coinDeactivateBtn);
        await driver.tap(coinDeactivateBtn);
        await driver.waitFor(confirmDeactivateBtn);
        await driver.tap(confirmDeactivateBtn);
      });
    });

    test('| -5.38- | Delete RICK wallet', () async {
      await driver.waitFor(more);
      await driver.tap(more);

      await driver.waitFor(settings);
      await driver.tap(settings);

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
