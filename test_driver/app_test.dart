import 'dart:io';
import 'dart:math';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';


void main() {
  FlutterDriver driver;
  final rnd = Random();
  
  // Variables
  final Map<String, String> envVars = Platform.environment;
  bool isAndroid = false;

  var seed = ['a', 'b'];
  var mortysRickAddress = '';
  var ricksMortyAddress = '';
  const String sendAmount = '0.1'; // TODO(dth): make rnd.nextFloat
  const password = '           a';
  const int coolOffTime = 2;
  int globalDelay() => 500 + rnd.nextInt(500);
  const testNewWalletName = 'testNewWalletName';

                              
                              
  //------------------------ Scenario 1 Finders ----------------------------------------------//
  //           Scenario 1 is reserved for creation of a new wallet.                           //
  //-----(Scenario 1)----- Create New Wallet Screens ------(Scenario 1)-----------------------//
  final SerializableFinder createWalletScreen = find.text('CREATE A WALLET');                 // - 1 Create Wallet Screen
  final SerializableFinder createWalletNameScreen = find.text('WELCOME');                     // - 2 Create Wallet Name Screen
  final SerializableFinder newSeedPhraseScreen = find.text('New Account');                    // - 3 New Seed Phrase Screen
  final SerializableFinder checkSeedPhraseScreen = find.text('Check seed phrase');            // - 4 Verify Seed Phrase Screen 
  final SerializableFinder createPasswordScreen = find.text('CREATE A PASSWORD');             // - 5 Create Password Screen
  final SerializableFinder disclaimerScreen = find.text('Disclaimer & ToS');                  // - 6 Accept Disclaimer Screen
  final SerializableFinder createaPINScreen = find.text('Create PIN');                        // - 7 Create PIN Code Screen
  final SerializableFinder settingsScreen = find.byValueKey('settings-title');                // - 8 Settings Screen (Delete Wallet)
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
  //-------------------------- 8 - Settings Screen -------------------------------------------//
  final SerializableFinder settingsScrollable = find.byValueKey('settings-scrollable');       //
  final SerializableFinder settingsDeleteWallet = find.text('Delete Wallet');                 //
  final SerializableFinder enterPasswordField = find.byValueKey('enter-password-field');      //
  final SerializableFinder unlock = find.byValueKey('unlock-wallet');                         //
  final SerializableFinder delete = find.byValueKey('delete-wallet');                         //
  //-----------------------------------END----------------------------------------------------//
  //---------------------------END-(Scenario-1)-END-------------------------------------------//
  //-----------------------------------END----------------------------------------------------//





  //----------------------------- Scenario 2 Finders -----------------------------------------//   - 1 Restore Wallet Screen
  //              Scenario 2 is reserved for restoration of a wallet.                         //   - 2 Create Wallet Name Screen
  //----------(Scenario 2)---------- Restore Wallet ----------(Scenario 2)--------------------//   - 3 Enter Your Seed Screen
  //         !!!!----- Mostly the same Finders as per Scenario 1 ------!!!!!                  //   - 4 Create Password Screen
  final SerializableFinder restoreWalletScreen = find.text('RESTORE');                        //   - 5 Accept Disclaimer Screen
  final SerializableFinder restoreWalletBtn = find.byValueKey('restoreWallet');               //   - 6 Create PIN Code Screen
  final SerializableFinder enterYourSeedScreen = find.text('Enter Your Seed Phrase');         //   - 7 Setting Screen (Delete Wallet)
  final SerializableFinder restoreSeedField = find.byValueKey('restore-seed-field');          //
  final SerializableFinder confirmSeedBtn = find.byValueKey('confirm-seed-button');           //
  final SerializableFinder allowCustomSeed = find.byValueKey('checkbox-custom-seed');         //
  //-----------------------------------END----------------------------------------------------//
  //---------------------------END-(Scenario-2)-END-------------------------------------------//  
  //-----------------------------------END----------------------------------------------------//






  //-------------------------- Scenario 3 Finders --------------------------------------------//  - 1 Create Wallet Screen
  //             Scenario 3 is reserved for screens such as Markets,                          //  - 2 Create Wallet Name Screen
  //                  Feed and playing around with Settings                                   //  - 3 New Seed Phrase Screen
  //-----(Scenario 3)----- Add Coins, Browse Markets, Feed ------(Scenario 3)-----------------//  - 4 Verify Seed Phrase Screen
  //        !!!!----- Mostly the same Finders as per Scenario 1------!!!!!                    //  - 5 Create Password Screen
  final SerializableFinder markets = find.byValueKey('nav-markets');
  final SerializableFinder marketsPriceScreen = find.text('PRICE');
  final SerializableFinder marketsOrderBookScreen = find.text('ORDER BOOK');
  final SerializableFinder marketsPriceBtn = find.text('PRICE');
  final SerializableFinder marketsOrderBookBtn = find.text('ORDER BOOK');

  final SerializableFinder marketsSelectCoinPopupScreen = find.text('Select Coin');
  final SerializableFinder marketsOrderBookEmptyScreen = find.text('Please select coins');

  final SerializableFinder marketsOrderBookTable = find.byValueKey('order-book-table');
  final SerializableFinder marketsCoinSelectLeft = find.byValueKey('coin-select-left');
  final SerializableFinder marketsCoinSelectRight = find.byValueKey('coin-select-right');
  final SerializableFinder marketsCoinSelectSwap = find.byValueKey('coin-select-swap');

  final SerializableFinder marketsCoinSelectClear = find.text('Clear');
  final SerializableFinder marketsCoinSelectBTC = find.byValueKey('coin-select-option-BTC');
  final SerializableFinder marketsCoinSelectKMD = find.byValueKey('coin-select-option-KMD');
  


  final SerializableFinder feed = find.byValueKey('nav-news');
  final SerializableFinder feedScreen = find.text('NEWS FEED');

  final SerializableFinder settings = find.byValueKey('nav-settings');

  //final SerializableFinder switchTile = find.text('Activate PIN protection');
  //final SerializableFinder switchPin = find.byValueKey('settings-activate-pin');
  final SerializableFinder logout = find.byValueKey('settings-logout');
  final SerializableFinder logoutYes = find.byValueKey('settings-logout-yes');
  //final SerializableFinder logoutCancel = find.byValueKey('settings-logout-cancel');
  //                                                                                          //  - 6 Accept Disclaimer Screen
  //                                                                                          //  - 7 Create PIN Code Screen
  //                                                                                          //  - 8 Portfolio Screen
  //-----------------------------------END----------------------------------------------------//  - 9 Markets Screen  
  //---------------------------END-(Scenario-3)-END-------------------------------------------//  - 10 Feed Screen  
  //-----------------------------------END----------------------------------------------------//  - 11 Setting Screen  






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
  final SerializableFinder bitcoin = find.text('BITCOIN');
  final SerializableFinder komodo = find.text('KOMODO');

  final SerializableFinder login = find.text('LOGIN');

  final SerializableFinder dex = find.byValueKey('nav-dex');
  final SerializableFinder amountField = find.byValueKey('send-amount-field');
  final SerializableFinder recipientsAddress = find.byValueKey('send-address-field');
  final SerializableFinder successSend = find.text('Success!');
  final SerializableFinder address = find.byValueKey('coin-details-address');
  final SerializableFinder receive = find.text('RECEIVE');
  final SerializableFinder close = find.text('CLOSE');
  final SerializableFinder send = find.byValueKey('secondary-button-send');
  //final SerializableFinder cancel = find.byValueKey('secondary-button-cancel');
  final SerializableFinder withdraw = find.byValueKey('primary-button-withdraw');
  final SerializableFinder confirm = find.byValueKey('primary-button-confirm');
  //final SerializableFinder customFee = find.byValueKey('send-toggle-customfee');


  final SerializableFinder orderMatched = find.text('Order matched');
  final SerializableFinder step0outOf3 = find.byValueKey('Step 0/3');
  
  //-----------------------------------END----------------------------------------------------//
  //---------------------------END-(Scenario-4)-END-------------------------------------------//
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



  group(     ' | (Scenario 1) Create new wallet  |', () {
//------------------------(Scenario 1)------------------------------//
//----------------- Group Create New Wallet ------------------------//
//------------------------------------------------------------------//
    test('-1.1- | Check create wallet btn works', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');

      await driver.waitFor(createWalletBtn);
      await driver.tap(createWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    // (1)back-btn test from wallet-naming-screen
    test('-1.2- | Check back-btn from wallet-naming-screen (works)', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
    });
    

    test('-1.3- | Check create-wallet-btn works (2nd time)', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');

      await driver.waitFor(createWalletScreen);
      await driver.tap(createWalletScreen);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('-1.4- | Create wallet name', () async {
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
    test('-1.5- | Check back-btn from save-seed-screen (works)', () async {
      expect(await driver.getText(newSeedPhraseScreen), 'New Account');

      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('-1.6- | Check wallet name $testNewWalletName still on naming-wallet-screen after going back from save-seed-screen.', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(find.text(testNewWalletName));

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    // (3)back-btn test from wallet-naming-screen
    test('-1.7- | Check back-btn from wallet-naming-screen works (2nd time)', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
    });


    test('-1.8- | Check wallet with name $testNewWalletName was NOT created after comeback from save-seed-screen', () async {
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


    test('-1.9- | Create wallet btn works (3rd time)', () async {
      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');

      await driver.waitFor(createWalletBtn);
      await driver.tap(createWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('-1.10- | Check you CAN NOT create a wallet without a name i.e. after tapping on'
    ' grey-setup-btn with empty wallet-name-field, we should stay on the same page.', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);
      print('untappable tap...');

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('-1.11- | Check you can create a wallet with name = $testNewWalletName', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText(testNewWalletName);
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(await driver.getText(newSeedPhraseScreen), 'New Account');
    });


    test('-1.12- | Check seed refresh works - test would fail if initialSeed == postRefreshSeed', () async {
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


    test('-1.13- | Check if seed copy/paste works', () async {
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


    test('-1.14- | Check Go-Back-And-Check-Again button works', () async {
      expect(await driver.getText(checkSeedPhraseScreen), 'Check seed phrase');

      await driver.scrollIntoView(continueSeedVerification);
      await driver.waitFor(goBackAndCheckSeedAgain);
      await driver.tap(goBackAndCheckSeedAgain);

      expect(await driver.getText(newSeedPhraseScreen), 'New Account');
    });


    test('-1.15- | Save seed', () async {
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


    test('-1.16- | Verify seed', () async {
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
    

    test('-1.17- | Create password', () async {
      expect(await driver.getText(createPasswordScreen), 'CREATE A PASSWORD');

      await driver.waitFor(passwordCreate);
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await driver.waitFor(passwordRetype);
      await driver.tap(passwordRetype);
      await driver.enterText(password);
      await driver.waitFor(passwordConfirm);
      await driver.tap(passwordConfirm);

      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');
    });


    test('-1.18- | Validate disclaimer', () async {
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


    

    test('-1.19- | Create PIN', () async {
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


    test('-1.20- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('-1.21- | Enter settings screen', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');

      await driver.waitFor(settings);
      await driver.tap(settings);

      expect(await driver.getText(settingsScreen), 'SETTINGS');
    });


    test('-1.22- | Delete new wallet', () async {
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

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
    });//----------------------END-(Scenario-1)-END------------------------//
  });//--------------------- Group Create New Wallet ----------------------//
  //---------------------------END-(Scenario-1)-END------------------------//
  
  



  group(     ' | (Scenario 2) Restore a wallet  |', () {
  //--------------------------(Scenario 2)---------------------------------//
  //-------------------- Group Restore A Wallet ---------------------------//
  //-----------------------------------------------------------------------//
    test('-2.0- | Delay: $coolOffTime min - Let mm2 cool off a bit', () async {
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    }, timeout: const Timeout(Duration(minutes: coolOffTime + 1)));

    test('-2.1- | Check restore-wallet-btn works', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    // (1)back-btn test from wallet-naming-screen
    test('-2.2- | Check back-btn from wallet-naming-screen (works)', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    });


    test('-2.3- | Check restore-wallet-btn works (2nd time)', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('-2.4- | Create wallet name', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText(testNewWalletName);
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');
    });


    test('-2.5- | Restore wallet from seed "a" ', () async {
      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');

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


    test('-2.6- | Create password', () async {
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


    test('-2.7- | Validate disclaimer', () async {
      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');

      await driver.scrollUntilVisible(disclamerScrollable,
          endDisclamerScrollable,
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


    test('-2.8- | Create PIN', () async {
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


    test('-2.9- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('-2.10- | Enter settings screen', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');

      await driver.waitFor(settings);
      await driver.tap(settings);

      expect(await driver.getText(settingsScreen), 'SETTINGS');
    });


    test('-2.11- | Delete newly restored wallet', () async {
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

      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    });//----------------------END-(Scenario-2)-END------------------------//
  });//---------------------- Group Restore A Wallet ----------------------//
  //---------------------------END-(Scenario-2)-END------------------------//

  
  


  group(     ' | (Scenario 3) Markets, Feed and Settings  |', () {
  //--------------------------(Scenario 3)---------------------------------//
  //---------------- Group Markets, Feed and Settings ---------------------//
  //-----------------------------------------------------------------------//
    test('-3.0- | Delay: $coolOffTime min - Let mm2 cool off a bit', () async {
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    }, timeout: const Timeout(Duration(minutes: coolOffTime + 1)));


    test('-3.1- | Check restore-wallet-btn works', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    //(1)back-btn test from wallet-naming-screen
    test('-3.2- | Check back-btn from wallet-naming-screen (works)', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(back);
      await driver.tap(back);

      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    });


    test('-3.3- | Check restore-wallet-btn works (2nd time)', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('-3.4- | Create wallet name', () async {
      expect(await driver.getText(createWalletNameScreen), 'WELCOME');

      await driver.waitFor(nameWalletField);
      await driver.tap(nameWalletField);
      await driver.enterText(testNewWalletName);
      await driver.scrollUntilVisible(welcomeScrollable, setup, dyScroll: -300);
      await driver.waitFor(setup);
      await driver.tap(setup);

      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');
    });


    test('-3.5- | Restore wallet from seed "a" ', () async {
      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');

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


    test('-3.6- | Create password', () async {
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


    test('-3.7- | Validate disclaimer', () async {
      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');

      await driver.scrollUntilVisible(disclamerScrollable,
          endDisclamerScrollable,
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


    test('-3.8- | Create PIN', () async {
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


    test('-3.9- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('-3.10- | Check Markets-tab-nav-btn works', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');

      await driver.waitFor(markets);
      await driver.tap(markets);

      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');
    });


    test('-3.11- | Check order-book-nav-btn works', () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(marketsOrderBookBtn);
      await driver.tap(marketsOrderBookBtn);

      expect(await driver.getText(marketsOrderBookEmptyScreen), 'Please select coins');
    });


    test('-3.12- | Check price-nav-btn works', () async {
      expect(await driver.getText(marketsOrderBookEmptyScreen), 'Please select coins');

      await driver.waitFor(marketsPriceBtn);
      await driver.tap(marketsPriceBtn);

      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    });


    test('-3.13- | Check pressing on coin in price-screen moves you to order-book-screen and pops-up Select-Coin-Popup-Screen', () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(bitcoin);
      await driver.tap(bitcoin);

      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');
    });


    test('-3.14- | Check pressing on grey btn BTC/BTC in select-coin-pop-up does not do anything', () async {
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');

      await driver.waitFor(marketsCoinSelectBTC);
      await driver.tap(marketsCoinSelectBTC);

      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');
    });


    test('-3.15- | Check pressing on BTC/KMD in select-coin-pop-up brings up order-book-table', () async {
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');

      await driver.waitFor(marketsCoinSelectKMD);
      await driver.tap(marketsCoinSelectKMD);

      await driver.waitFor(marketsOrderBookTable);

      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');
    });

    
    // TODO(dth): enhancement - get values from both fields and make sure they ,indeed, swap.
    test('-3.16- | Confirm coin-swap-btn works.', () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(marketsCoinSelectSwap);
      await driver.tap(marketsCoinSelectSwap);

      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');
    });


    test('-3.17- | Check coin-select-left button brings up select-coin-screen', () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(marketsCoinSelectLeft);
      await driver.tap(marketsCoinSelectLeft);

      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');
    });


    test('-3.18- | Confirm you can clear coin-select-left-btn field and order-book-table will dissapear', () async {
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');

      await driver.waitFor(marketsCoinSelectClear);
      await driver.tap(marketsCoinSelectClear);
      
      expect(await driver.getText(marketsOrderBookEmptyScreen), 'Please select coins');
    });


    test('-3.19- | Confirm coin-select-right button brings up select-coin-screen', () async {
      expect(await driver.getText(marketsOrderBookEmptyScreen), 'Please select coins');

      await driver.waitFor(marketsCoinSelectRight);
      await driver.tap(marketsCoinSelectRight);
      
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');
    });


    test('-3.20- | Confirm you can clear coin-select-right field', () async {
      expect(await driver.getText(marketsSelectCoinPopupScreen), 'Select Coin');

      await driver.waitFor(marketsCoinSelectClear);
      await driver.tap(marketsCoinSelectClear);
      
      expect(await driver.getText(marketsOrderBookEmptyScreen), 'Please select coins');
    });


    test('-3.21- | Check FEED screen navigation works', () async {
      expect(await driver.getText(marketsPriceScreen), 'PRICE');
      expect(await driver.getText(marketsOrderBookScreen), 'ORDER BOOK');

      await driver.waitFor(feed);
      await driver.tap(feed);
      
      expect(await driver.getText(feedScreen), 'NEWS FEED');
    });


    test('-3.22- | Check SETTINGS screen navigation works', () async {
      expect(await driver.getText(feedScreen), 'NEWS FEED');

      await driver.waitFor(settings);
      await driver.tap(settings);
      
      expect(await driver.getText(settingsScreen), 'SETTINGS');
    });
    

    test('-3.23- | Delete new wallet', () async {
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

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
    });//----------------------END-(Scenario-3)-END------------------------//
  });//---------------- Group Markets, Feed and Settings ------------------//
  //---------------------------END-(Scenario-3)-END------------------------//






  group(     ' | (Scenario 4) Send/Receive and Swaps!  |', () {
  //--------------------------(Scenario 4)---------------------------------//
  //---------------- Group Send/Receive and Swaps -------------------------//
  //-----------------------------------------------------------------------//
    test('-4.0- | Delay: $coolOffTime min - Let mm2 cool off a bit', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});

      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    }, timeout: const Timeout(Duration(minutes: coolOffTime + 1)));



    test('-4.1- | Restore-btn works - MORTY Wallet ', () async {
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');

      await driver.waitFor(restoreWalletBtn);
      await driver.tap(restoreWalletBtn);

      expect(await driver.getText(createWalletNameScreen), 'WELCOME');
    });


    test('-4.2- | Create wallet name - MORTY Wallet ', () async {
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
    

    test('-4.3- | Enter MORTY seed', () async {
      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');

      await driver.waitFor(find.byValueKey('restore-seed-field'));
      await driver.tap(find.byValueKey('restore-seed-field'));
      await driver.enterText(envVars['MORTY']);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(find.byValueKey('confirm-seed-button'));
      await driver.tap(find.byValueKey('confirm-seed-button'));

      expect(await driver.getText(createPasswordScreen),'CREATE A PASSWORD');
    });


    test('-4.4- | Create MORTY password', () async {
      expect(await driver.getText(createPasswordScreen),'CREATE A PASSWORD');

      await driver.waitFor(passwordCreate);
      await driver.tap(passwordCreate);
      await driver.enterText(password);
      await driver.waitFor(passwordRetype);
      await driver.tap(passwordRetype);
      await driver.enterText(password);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(find.text('CONFIRM PASSWORD'));
      await driver.tap(find.text('CONFIRM PASSWORD'));

      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');
    });


    test('-4.5- | Validate MORTY disclaimer', () async {
      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');

      await driver.scrollUntilVisible(find.byValueKey('scroll-disclaimer'),
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5300);
      await driver.tap(find.byValueKey('checkbox-eula'));
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.tap(find.byValueKey('next-disclaimer'));

      expect(await driver.getText(createaPINScreen), 'Create PIN');
    });


    test('-4.6- | Create MORTY PIN ', () async {
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


    test('-4.7- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(bitcoin), 'BITCOIN');
      expect(await driver.getText(komodo), 'KOMODO');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('-4.7- | Activate rick and morty coins', () async {

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


    
    test('-4.8- | Get mortysRickAddress', () async {
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
    });});


    test('-4.9- | Logout from MORTY wallet', () async {
      await driver.waitFor(settings);
      await driver.tap(settings);
      await driver.waitFor(logout);
      await driver.tap(logout);
      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);

      expect(await driver.getText(createWalletScreen), 'CREATE A WALLET');
      expect(await driver.getText(restoreWalletScreen), 'RESTORE');
    });

    // RELOG-2
    test('-4.10- | Restore RICK wallet (Delay: $coolOffTime min) - Let mm2 cool off a bit', () async {
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});

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

      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');
    }, timeout: const Timeout(Duration(minutes: coolOffTime + 1)));
    

    test('-4.11- | Restore RICK seed', () async {
      expect(await driver.getText(enterYourSeedScreen), 'Enter Your Seed Phrase');

      await driver.waitFor(find.byValueKey('restore-seed-field'));
      await driver.tap(find.byValueKey('restore-seed-field'));
      await driver.enterText(envVars['RICK']);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(find.byValueKey('confirm-seed-button'));
      await driver.tap(find.byValueKey('confirm-seed-button'));

    });


    test('-4.12- | Create RICK password', () async {
      expect(await driver.getText(createPasswordScreen), 'CREATE A PASSWORD');

      await driver.waitFor(passwordCreate);
      await driver.tap(passwordCreate);
      await driver.enterText(password);

      await driver.waitFor(passwordRetype);
      await driver.tap(passwordRetype);
      await driver.enterText(password);
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(find.text('CONFIRM PASSWORD'));
      await driver.tap(find.text('CONFIRM PASSWORD'));

      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');
    });


    test('-4.13- | Validate RICK disclaimer', () async {
      expect(await driver.getText(disclaimerScreen), 'Disclaimer & ToS');

      await driver.scrollUntilVisible(find.byValueKey('scroll-disclaimer'),
          find.byValueKey('end-list-disclaimer'),
          dyScroll: -5000);
      await driver.waitFor(find.byValueKey('checkbox-eula'));
      await driver.tap(find.byValueKey('checkbox-eula'));
      await driver.waitFor(find.byValueKey('checkbox-toc'));
      await driver.tap(find.byValueKey('checkbox-toc'));
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(find.byValueKey('next-disclaimer'));
      await driver.tap(find.byValueKey('next-disclaimer'));

      expect(await driver.getText(createaPINScreen), 'Create PIN');
    });


    test('-4.14- | Create RICK PIN ', () async {
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


    test('-4.15- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(morty), 'MORTY');
      expect(await driver.getText(rick), 'RICK');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('-4.16- | Get ricksMortyAddress', () async {
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
    });});
    

    test('-4.17- | Send RICK from rick to morty', () async {
      await driver.waitFor(rick);
      await driver.tap(rick);
      print('from rick $ricksMortyAddress to morty $mortysRickAddress');
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
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(confirm);
      await driver.tap(confirm);

      await driver.waitFor(successSend);
      await driver.waitForAbsent(successSend);

      await driver.waitFor(back);
      await driver.tap(back);
    });},timeout: const Timeout(Duration(minutes: 2)));


    test('-4.18- | Logout from RICK wallet', () async {
      await driver.waitFor(settings);
      await driver.tap(settings);

      await driver.waitFor(logout);
      await driver.tap(logout);

      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);
    });
    

    // RELOG-3
    test('-4.19- | Relog to MORTY (Delay: $coolOffTime min) - Let mm2 cool off a bit', () async {
      await driver.scrollIntoView(morty);
      await driver.scrollIntoView(rick);
      await driver.scrollIntoView(morty);
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});
      await driver.scrollIntoView(rick);
      await driver.scrollIntoView(morty);
      await driver.scrollIntoView(rick);
    },timeout: const Timeout(Duration(minutes: coolOffTime + 1)));


    test('-4.20- | Login to MORTY wallet', () async {
      await driver.tap(morty);

      await driver.tap(enterPasswordField);
      await driver.enterText(password);

      await driver.scrollIntoView(login);
      await driver.tap(login);
    });


    /* for PIN protection
    test('-31- | Enter PIN for MORTY wallet', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });
    */


    // MM2-Login-4
    test('-4.21- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(morty), 'MORTY');
      expect(await driver.getText(rick), 'RICK');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('-4.22- | Check RICK transfer confirmed', () async {
      await driver.tap(rick);
      await driver.runUnsynchronized(() async {
      await driver.waitFor(find.text('+$sendAmount RICK'));
      await driver.waitFor(back);
      await driver.tap(back);
    });});


    test('-4.23- | Send MORTY from morty to rick', () async {
      await driver.tap(morty);
      print('from morty $mortysRickAddress to rick $ricksMortyAddress'); // TODO(dth): proper logging
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
      await Future<void>.delayed(Duration(milliseconds: globalDelay()), () {});
      await driver.waitFor(confirm);
      await driver.tap(confirm);

      await driver.waitFor(successSend);
      await driver.waitForAbsent(successSend);

      await driver.waitFor(back);
      await driver.tap(back);
    });},timeout: const Timeout(Duration(minutes: 2)));


    test('-4.24- | LOGOUT from MORTY wallet', () async {
      await driver.waitFor(settings);
      await driver.tap(settings);

      await driver.waitFor(logout);
      await driver.tap(logout);

      await driver.waitFor(logoutYes);
      await driver.tap(logoutYes);
    });


    // TODO(dth): figure out tests failing even though they pass.
    // RELOG-4
    test('-4.24- | Relog to RICK (Delay: $coolOffTime min) - Let mm2 cool off a bit', () async {
      await driver.scrollIntoView(morty);
      await driver.scrollIntoView(rick);
      await driver.scrollIntoView(morty);
      await Future<void>.delayed(const Duration(minutes: coolOffTime), () {});
      await driver.scrollIntoView(rick);
      await driver.scrollIntoView(morty);
      await driver.scrollIntoView(rick);
    },timeout: const Timeout(Duration(minutes: coolOffTime + 1)));


    test('-4.25- | LOGIN to RICK wallet ', () async {
      await driver.tap(rick);

      await driver.tap(enterPasswordField);
      await driver.enterText(password);

      await driver.scrollIntoView(login);
      await driver.tap(login);
    });


    /* for PIN protection
    test('-38- | Enter PIN for RICK wallet', () async {
      await Future<void>.delayed(const Duration(milliseconds: 1000), () {});
      for (int i = 0; i < 6; i++) {
        await driver.tap(find.text('0'));
      }
    });
    */


    // MM2-Login-5
    test('-4.26- | Check if mm2 successfully connected', () async {
      expect(await driver.getText(morty), 'MORTY');
      expect(await driver.getText(rick), 'RICK');
    }, timeout: const Timeout(Duration(minutes: 1)));


    test('-4.27- | Check transfer from MORTY confirmed', () async {
      await driver.scrollIntoView(morty);
      await driver.tap(morty);

      await driver.runUnsynchronized(() async {
      await driver.waitFor(find.text('+$sendAmount MORTY'));

      await driver.waitFor(back);
      await driver.tap(back);
    });});


    test('-4.28- | Swap MORTY for RICK', () async{
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

      await driver.scrollIntoView(find.byValueKey('ask-item-0'));
      await driver.waitFor(find.byValueKey('ask-item-0'));
      await driver.tap(find.byValueKey('ask-item-0'));

      await driver.scrollIntoView(find.byValueKey('trade-button'));
      await driver.waitFor(find.byValueKey('trade-button'));
      await driver.tap(find.byValueKey('trade-button'));

      await driver.waitFor(find.byValueKey('swap-detail-title'));
      await driver.scrollIntoView(find.byValueKey('confirm-swap-button'));
      await driver.waitFor(find.byValueKey('confirm-swap-button'));
      await driver.tap(find.byValueKey('confirm-swap-button'));

      await driver.waitForAbsent(step0outOf3);
      expect(await driver.getText(orderMatched), 'Order matched');
      await driver.tap(find.byValueKey('swap-detail-back-button'));
    });
  
    test('-4.29- | Send feedback', () async {
      await driver.tap(settings);
      await driver.scrollUntilVisible(settingsScrollable,
          find.byValueKey('setting-title-feedback'),
          dyScroll: -300);
      await driver.tap(find.byValueKey('setting-title-feedback'));
      await driver.tap(find.byValueKey('setting-share-button'));
    });//----------------------END-(Scenario-4)-END------------------------//
  });//------------------ Group Send/Receive and Swaps --------------------//
  //---------------------------END-(Scenario-4)-END------------------------//
  




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
  
*/
}