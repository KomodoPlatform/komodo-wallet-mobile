import 'dart:math';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';


void main() {
  FlutterDriver driver;
  final rnd = Random();
  int globalDelay() => 700 + rnd.nextInt(500);
  bool isAndroid = false;

  var seed = ['a', 'b'];
  const password = '           a';
  const testNewWalletName = 'testNewWalletName';


  //------------------------ Scenario 1 Finders ----------------------------------------------//  - 1 Create Wallet Screen
  //           Scenario 1 is reserved for creation of a new wallet.                           //  - 2 Create Wallet Name Screen
  //-----(Scenario 1)----- Create New Wallet Screens ------(Scenario 1)-----------------------//  - 3 New Seed Phrase Screen
  final SerializableFinder createWalletScreen = find.text('CREATE A WALLET');                 //  - 4 Verify Seed Phrase Screen
  final SerializableFinder createWalletNameScreen = find.text('WELCOME');                     //  - 5 Create Password Screen
  final SerializableFinder newSeedPhraseScreen = find.text('New Account');                    //  - 6 Accept Disclaimer Screen
  final SerializableFinder checkSeedPhraseScreen = find.text('Check seed phrase');            //  - 7 Create PIN Code Screen
  final SerializableFinder createPasswordScreen = find.text('CREATE A PASSWORD');             //  - 8 Main Portfolio Screen
  final SerializableFinder disclaimerScreen = find.text('Disclaimer & ToS');                  //  - 9 Settings Screen (Delete Wallet)
  final SerializableFinder createaPINScreen = find.text('Create PIN');                        //
  final SerializableFinder settingsScreen = find.byValueKey('settings-title');                //
  //------------------------------------------------------------------------------------------//
  /*--------*/ final SerializableFinder back = find.byTooltip('Back'); /*---------------------*/
  //---------------------- 1 - Create wallet screen ------------------------------------------//
  final SerializableFinder createWalletBtn = find.byValueKey('createWalletButton');           //
  //---------------------- 2 - Create wallet name screen  ------------------------------------//
  final SerializableFinder welcomeScrollable = find.byValueKey('welcome-scrollable');         //
  final SerializableFinder nameWalletField = find.byValueKey('name-wallet-field');            //
  final SerializableFinder setup = find.text('LET\'S GET SET UP!');                           //
  //---------------------- 3 - New seed phrase screen ----------------------------------------//
  final SerializableFinder newAccountScrollable = find.byValueKey('new-account-scrollable');  //
  final SerializableFinder seedPhrase = find.byValueKey('seed-phrase');                       //
  final SerializableFinder seedRefresh = find.byValueKey('seed-refresh');                     //
  final SerializableFinder seedCopy = find.byValueKey('seed-copy');                           //
  final SerializableFinder next = find.text('NEXT');                                          //
  //---------------------- 4 - Verify seed phrase screen -------------------------------------//
  final SerializableFinder pasteIOS = find.text('Paste');                                     //
  final SerializableFinder pasteAndroid = find.text('PASTE');                                 //
  final SerializableFinder continueSeedVerification = find.text('CONTINUE');                  //
  final SerializableFinder goBackAndCheckSeedAgain = find.text('GO BACK AND CHECK AGAIN');    //
  final SerializableFinder whichWordField = find.byValueKey('which-word-field');              //
  final SerializableFinder whichWordText = find.byValueKey('which-word');                     //
  //---------------------- 5 - Create password screen  ---------------------------------------//
  final SerializableFinder passwordCreate = find.byValueKey('create-password-field');         //
  final SerializableFinder passwordRetype = find.byValueKey('create-password-field-confirm'); //
  final SerializableFinder passwordConfirm = find.text('CONFIRM PASSWORD');                   //
  //---------------------- 6 - Accept disclaimer screen  -------------------------------------//
  final SerializableFinder disclamerScrollable = find.byValueKey('scroll-disclaimer');        //
  final SerializableFinder endDisclamerScrollable = find.byValueKey('end-list-disclaimer');   //
  final SerializableFinder checkEula = find.byValueKey('checkbox-eula');                      //
  final SerializableFinder checkTOC = find.byValueKey('checkbox-toc');                        //
  final SerializableFinder disclaimerNext= find.byValueKey('next-disclaimer');                //
  //-------------------------- 7 - Create PIN screen -----------------------------------------//
  //   Its better not to expect() Create/Confirm PIN code, driver gets confused.              //
  //-------------------------- 8 Main Portfolio Screen ---------------------------------------//
  final SerializableFinder bitcoin = find.text('BITCOIN');                                    //
  final SerializableFinder komodo = find.text('KOMODO');                                      //
  //-------------------------- 9 - Settings Screen -------------------------------------------//
  final SerializableFinder settings = find.byValueKey('side-nav-settings');                        //
  final SerializableFinder more = find.byValueKey('main-nav-more');
  final SerializableFinder settingsScrollable = find.byValueKey('settings-scrollable');       //
  final SerializableFinder settingsDeleteWallet = find.text('Delete Wallet');                 //
  final SerializableFinder enterPasswordField = find.byValueKey('enter-password-field');      //
  final SerializableFinder unlock = find.byValueKey('unlock-wallet');                         //
  final SerializableFinder delete = find.byValueKey('delete-wallet');                         //
  //-----------------------------------END----------------------------------------------------//
  //---------------------------END-(Scenario-1)-END-------------------------------------------//
  //-----------------------------------END----------------------------------------------------//



  

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
    test('-0- | Print flutter driver health', () async {
      final Health health = await driver.checkHealth();
      print(health.status);
    });

    test('-0.1- | For experiments', () async {
      print('Enough with experiments for now!');
    });
  });



  group('| (Scenario 1) Create new wallet   ', () {
    test('| -1.1- | Check create wallet btn works', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');

      await driver.waitFor(createWalletBtn);
      await driver.tap(createWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    // (1)back-btn test from wallet-naming-screen
    test('| -1.2- | Check back-btn from wallet-naming-screen (works)', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
    });
    

    test('| -1.3- | Check create-wallet-btn works (2nd time)', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');

      await driver.waitFor(createWalletScreen);
      await driver.tap(createWalletScreen);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('| -1.4- | Create wallet name', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText(testNewWalletName);
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(await driver.getText(newSeedPhraseScreen), 'New Account');
    });


    // (2)back-btn test from save-seed-screen
    test('| -1.5- | Check back-btn from save-seed-screen (works)', () async {
      expect(await driver.getText(newSeedPhraseScreen), 'New Account');

      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('| -1.6- | Check wallet name $testNewWalletName still on naming-wallet-screen after going back from save-seed-screen.', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(find.text(testNewWalletName));

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    // (3)back-btn test from wallet-naming-screen
    test('| -1.7- | Check back-btn from wallet-naming-screen works (2nd time)', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
    });


    test('| -1.8- | Check wallet with name $testNewWalletName was NOT created after comeback from save-seed-screen', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');

      bool present = false;
      try {
        await driver.waitFor(find.text(testNewWalletName), timeout: const Duration(milliseconds: 1500));
        present = true;
      } catch (e) {
        present = false;
      }
      if (present){
        print('ALARM! ALARM! wallet is created after comeback from save-seed-screen. ALARM ALARM!');
        await driver.waitFor(find.text('NONE EXISTENT TEXT TO FAIL THE TEST'),
                                timeout: const Duration(seconds: 1));
      }

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
    });


    test('| -1.9- | Create wallet btn works (3rd time)', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');

      await driver.waitFor(createWalletBtn);
      await driver.tap(createWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('| -1.10- | Check you CAN NOT create a wallet without a name i.e. after tapping on'
    ' grey-setup-btn with empty wallet-name-field, we should stay on the same page.', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);
      print('untappable tap...');

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('| -1.11- | Check you can create a wallet with name = $testNewWalletName', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText(testNewWalletName);
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(await driver.getText(newSeedPhraseScreen), 'New Account');
    });


    test('| -1.12- | Check seed refresh works - test would fail if initialSeed == postRefreshSeed', () async {
      expect(await driver.getText(newSeedPhraseScreen), 'New Account');

      var initialSeed = '';
      await driver.waitFor(seedPhrase);
      await driver.getText(seedPhrase).then((val) {
        initialSeed = val;
      });
      await driver.waitFor(seedRefresh);
      await driver.tap(seedRefresh);
      await driver.getText(seedPhrase).then((val) async {
        if (initialSeed == val){
          await driver.waitFor(find.text('NONE EXISTENT TEXT TO FAIL THE TEST'),
                                timeout: const Duration(seconds: 1));
        }
      });

      expect(await driver.getText(newSeedPhraseScreen), 'New Account');
    });

    
    test('| -1.13- | Check if seed copy/paste works', () async {
      expect(await driver.getText(newSeedPhraseScreen), 'New Account');

      final pasteFinder = isAndroid ? pasteAndroid : pasteIOS;
      await driver.waitFor(seedCopy);
      await driver.tap(seedCopy);
      await driver.scrollUntilVisible(newAccountScrollable, next, dyScroll: -300);
      await driver.waitFor(next);
      await driver.tap(next); 

      expect(await driver.getText(checkSeedPhraseScreen), 'Check seed phrase');

      await driver.waitFor(whichWordField);
      await driver.tap(whichWordField);
      await driver.scroll(whichWordField, 0, 0, const Duration(milliseconds: 1100));
      await driver.waitFor(pasteFinder);
      await driver.tap(pasteFinder);

      expect(await driver.getText(checkSeedPhraseScreen), 'Check seed phrase');
    });


    test('| -1.14- | Check Go-Back-And-Check-Again button works', () async {
      expect(await driver.getText(checkSeedPhraseScreen), 'Check seed phrase');

      await driver.scrollIntoView(continueSeedVerification);
      await driver.waitFor(goBackAndCheckSeedAgain);
      await driver.tap(goBackAndCheckSeedAgain);

      expect(await driver.getText(newSeedPhraseScreen), 'New Account');
    });

    
    test('| -1.15- | Save seed', () async {
      expect(await driver.getText(newSeedPhraseScreen), 'New Account');

      await driver.waitFor(seedPhrase);
      await driver.getText(seedPhrase).then((val) {
        seed = val.split(' ');
      });

      await driver.scrollUntilVisible(newAccountScrollable, next, dyScroll: -300);
      await driver.waitFor(next);
      await driver.tap(next);
      expect(await driver.getText(checkSeedPhraseScreen), 'Check seed phrase');
    });


    test('| -1.16- | Verify seed', () async {
      expect(await driver.getText(checkSeedPhraseScreen), 'Check seed phrase');
      int whichWord;
      
      for (int i = 0; i <= 2; i++){
        await driver.waitFor(whichWordText);
        await driver.getText(whichWordText).then((val) {
          whichWord = int.tryParse(val.split(' ')[3].replaceAll(RegExp(r'[^\w\s]+'),''))  - 1;
        });
        await driver.waitFor(whichWordField);
        await driver.tap(whichWordField);
        await driver.enterText(seed[whichWord]);
        await driver.scrollIntoView(continueSeedVerification);
        await driver.waitFor(continueSeedVerification);
        await driver.tap(continueSeedVerification);
      }
      expect(await driver.getText(createPasswordScreen), 'CREATE A PASSWORD');
    });
    

    test('| -1.17- | Create password', () async {
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


    test('| -1.18- | Validate disclaimer', () async {
      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');

      await driver.scrollUntilVisible(disclamerScrollable,
          endDisclamerScrollable,
          dyScroll: -5450);
      await driver.waitFor(checkEula);
      await driver.tap(checkEula);
      await driver.waitFor(checkTOC);
      await driver.tap(checkTOC);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(disclaimerNext);
      await driver.tap(disclaimerNext);

      expect(await driver.getText(createaPINScreen), 'Create PIN');
    }, timeout: const Timeout(Duration(minutes: 1)));


    

    test('| -1.19- | Create PIN', () async {
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


    test('| -1.20- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('| -1.21- | Enter settings screen', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
      
      await driver.waitFor(more);
      await driver.tap(more);

      await driver.waitFor(settings);
      await driver.tap(settings);

      expect(await driver.getText(settingsScreen), 'SETTINGS');
    });


    test('| -1.22- | Delete new wallet', () async {
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
