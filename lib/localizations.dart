import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get createPin => Intl.message('Create PIN', name: 'createPin');
  String get enterPinCode =>
      Intl.message('Enter your PIN code', name: 'enterPinCode');
  String get login => Intl.message('login', name: 'login');
  String get newAccount => Intl.message('new account', name: 'newAccount');
  String get newAccountUpper =>
      Intl.message('New Account', name: 'newAccountUpper');
  String addingCoinSuccess(String name) => Intl.message(
        'Activated $name successfully !',
        name: 'addingCoinSuccess',
        args: [name],
      );
  String get connecting => Intl.message('Connecting...', name: 'connecting');
  String get addCoin => Intl.message('Activate coin', name: 'addCoin');
  String numberAssets(String assets) =>
      Intl.message("$assets Assets", args: [assets], name: 'numberAssets');
  String get enterSeedPhrase =>
      Intl.message('Enter Your Seed Phrase', name: 'enterSeedPhrase');
  String get exampleHintSeed =>
      Intl.message('Example: build case level ...', name: 'exampleHintSeed');
  String get confirm => Intl.message('confirm', name: 'confirm');
  String get buy => Intl.message('Buy', name: 'buy');
  String get sell => Intl.message('Sell', name: 'sell');
  String shareAddress(String coinName, String address) =>
      Intl.message('My $coinName address: \n$address',
          args: [coinName, address], name: 'shareAddress');
  String get withdraw => Intl.message('Withdraw', name: 'withdraw');
  String get errorValueEmpty =>
      Intl.message("Value is too high or low", name: 'errorValueEmpty');
  String get amount => Intl.message('Amount', name: 'amount');
  String get addressSend =>
      Intl.message('Recipients address', name: 'addressSend');
  String withdrawValue(String amount, String coinName) =>
      Intl.message('WITHDRAW $amount $coinName',
          args: [amount, coinName], name: 'withdrawValue');
  String get withdrawConfirm =>
      Intl.message('Confirm Withdrawal', name: 'withdrawConfirm');
  String get close => Intl.message('Close', name: 'close');
  String get confirmSeed =>
      Intl.message('Confirm Seed Phrase', name: 'confirmSeed');
  String get seedPhraseTitle =>
      Intl.message('Your new Seed Phrase', name: 'seedPhraseTitle');
  String get getBackupPhrase =>
      Intl.message('Important: Back up your seed phrase before proceeding!',
          name: 'getBackupPhrase');
  String get recommendSeedMessage =>
      Intl.message('We recommend storing it offline.',
          name: 'recommendSeedMessage');
  String get next => Intl.message('next', name: 'next');
  String get confirmPin => Intl.message('Confirm PIN code', name: 'confirmPin');
  String get errorTryAgain =>
      Intl.message('Error, please try again', name: 'errorTryAgain');
  String get settings => Intl.message('Settings', name: 'settings');
  String get security => Intl.message('Security', name: 'security');
  String get activateAccessPin =>
      Intl.message('Activate PIN protection', name: 'activateAccessPin');
  String get lockScreen => Intl.message('Screen is locked', name: 'lockScreen');
  String get changePin => Intl.message('Change PIN code', name: 'changePin');
  String get logout => Intl.message('Log Out', name: 'logout');
  String get max => Intl.message('MAX', name: 'max');
  String get amountToSell =>
      Intl.message('Amount To Sell', name: 'amountToSell');
  String get youWillReceived =>
      Intl.message('You will receive: ', name: 'youWillReceived');
  String get selectCoinToSell =>
      Intl.message('Select the coin you want to SELL',
          name: 'selectCoinToSell');
  String get selectCoinToBuy =>
      Intl.message('Select the coin you want to BUY', name: 'selectCoinToBuy');
  String get swap => Intl.message('swap', name: 'swap');
  String get buySuccessWaiting => Intl.message(
        'Swap issued, please wait!',
        name: 'buySuccessWaiting',
      );
  String buySuccessWaitingError(String seconde) => Intl.message(
        'Ordermatch ongoing, please wait $seconde seconds!',
        name: 'buySuccessWaiting',
        args: [seconde],
      );
  String get networkFee => Intl.message('Network fee', name: 'networkFee');
  String get commissionFee =>
      Intl.message('commission fee', name: 'commissionFee');
  String get portfolio => Intl.message('Portfolio', name: 'portfolio');
  String get checkOut => Intl.message('Check Out', name: 'checkOut');
  String get estimateValue =>
      Intl.message('Estimated Total Value', name: 'estimateValue');
  String get selectPaymentMethod =>
      Intl.message('Select Your Payment Method', name: 'selectPaymentMethod');
  String get volumes => Intl.message('Volumes', name: 'volumes');
  String get placeOrder => Intl.message('Place your order', name: 'placeOrder');
  String get comingSoon => Intl.message("Coming soon...", name: 'comingSoon');
  String get marketplace => Intl.message('Marketplace', name: 'marketplace');
  String get youAreSending =>
      Intl.message("You are sending:", name: 'youAreSending');
  String get code => Intl.message("Code: ", name: 'code');
  String get value => Intl.message("Value: ", name: 'value');
  String get paidWith => Intl.message("Paid with ", name: 'paidWith');
  String get errorValueNotEmpty =>
      Intl.message("Please input data", name: 'errorValueNotEmpty');
  String get errorAmountBalance =>
      Intl.message("Not enough balance", name: 'errorAmountBalance');
  String get errorNotAValidAddress =>
      Intl.message("Not a valid address", name: 'errorNotAValidAddress');
  String get toAddress => Intl.message("To address:", name: 'toAddress');
  String get receive => Intl.message("RECEIVE", name: 'receive');
  String get send => Intl.message("SEND", name: 'send');
  String get back => Intl.message("back", name: 'back');
  String get cancel => Intl.message("cancel", name: 'cancel');
  String get commingsoon =>
      Intl.message("TX details coming soon!", name: 'commingsoon');
  String get history => Intl.message("history", name: 'history');
  String get create => Intl.message("trade", name: 'trade');
  String get commingsoonGeneral =>
      Intl.message("Details coming soon!", name: 'commingsoonGeneral');
  String get orderMatching =>
      Intl.message("Order matching", name: 'orderMatching');
  String get orderMatched =>
      Intl.message("Order matched", name: 'orderMatched');
  String get swapOngoing => Intl.message("Swap ongoing", name: 'swapOngoing');
  String get swapSucceful =>
      Intl.message("Swap successful", name: 'swapSucceful');
  String get timeOut => Intl.message("Timeout", name: 'timeOut');
  String get swapFailed => Intl.message("Swap failed", name: 'swapFailed');
  String get errorTryLater =>
      Intl.message("Error, please try later", name: 'errorTryLater');
  String get feedback => Intl.message("Send Feedback", name: 'feedback');
  String get loadingOrderbook =>
      Intl.message("Loading orderbook...", name: 'loadingOrderbook');
  String get claim => Intl.message("claim", name: 'claim');
  String get claimTitle =>
      Intl.message("Claim your KMD reward?", name: 'claimTitle');
  String get success => Intl.message("Success!", name: 'success');
  String get noRewardYet =>
      Intl.message("No reward claimable - please try again in 1h.",
          name: 'noRewardYet');
  String get loading => Intl.message("Loading...", name: 'loading');
  String get dex => Intl.message("DEX", name: 'dex');
  String get media => Intl.message("News", name: 'media');
  String get newsFeed => Intl.message("News feed", name: 'newsFeed');
  String get appName => Intl.message("atomicDEX", name: 'appName');
  String get clipboard =>
      Intl.message("Copied to the clipboard", name: 'clipboard');
  String get from => Intl.message("From", name: 'from');
  String get to => Intl.message("To", name: 'to');
  String get txConfirmed => Intl.message("CONFIRMED", name: 'txConfirmed');
  String get txNotConfirmed => Intl.message("UNCONFIRMED", name: 'txConfirmed');
  String get txBlock => Intl.message("Block", name: 'txBlock');
  String get txConfirmations =>
      Intl.message("Confirmations", name: 'txConfirmations');
  String get txFee => Intl.message("Fee", name: 'txFee');
  String get txHash => Intl.message("Transaction ID", name: 'Tx Hash');
  String get noSwaps => Intl.message("No history.", name: 'noSwaps');
  String get trade => Intl.message("TRADE", name: 'trade');
  String get tradeCompleted =>
      Intl.message("SWAP COMPLETED!", name: 'tradeCompleted');
  String get step => Intl.message("Step", name: 'step');
  String get tradeDetail => Intl.message("TRADE DETAILS", name: 'tradeDetail');
  String get requestedTrade =>
      Intl.message("Requested Trade", name: 'requestedTrade');
  String get swapID => Intl.message("Swap ID", name: 'swapID');
  String get mediaBrowse => Intl.message("BROWSE", name: 'mediaBrowse');
  String get mediaSaved => Intl.message("SAVED", name: 'saved');
  String get articleFrom => Intl.message("AtomicDEX NEWS", name: 'articleFrom');
  String get mediaNotSavedDescription =>
      Intl.message("YOU HAVE NO SAVED ARTICLES",
          name: 'mediaNotSavedDescription');
  String get mediaBrowseFeed =>
      Intl.message("BROWSE FEED", name: 'mediaNotSavedDescription');
  String get mediaBy => Intl.message("By", name: 'mediaBy');
  String get lockScreenAuth =>
      Intl.message("Please authenticate!", name: 'lockScreenAuth');
  String get noTxs => Intl.message("No Transactions", name: 'noTxs');
  String get done => Intl.message("Done", name: 'done');
  String get selectCoinTitle =>
      Intl.message("Activate coins:", name: 'selectCoinTitle');
  String get selectCoinInfo =>
      Intl.message("Select the coins you want to add to your portfolio.",
          name: 'selectCoinInfo');
  String get noArticles =>
      Intl.message("No news - please check back later!", name: 'noArticles');
  String get infoTrade1 =>
      Intl.message("The swap request can not be undone and is a final event!",
          name: 'infoTrade1');
  String get infoTrade2 => Intl.message(
      "This transaction can take up to 10 mins - DONT close this application!",
      name: 'infoTrade2');
  String get swapDetailTitle =>
      Intl.message("CONFIRM EXCHANGE DETAILS", name: 'swapDetailTitle');
  String get checkSeedPhrase =>
      Intl.message("Check seed phrase", name: 'checkSeedPhrase');
  String get checkSeedPhraseTitle =>
      Intl.message("LET'S DOUBLE CHECK YOUR SEED PHRASE",
          name: 'checkSeedPhraseTitle');
  String get checkSeedPhraseInfo => Intl.message(
      "Your seed phrase is important - that's why we like to make sure it's correct. We'll ask you three different questions about your seed phrase to make sure you'll be able to easily restore your wallet whenever you want.",
      name: 'checkSeedPhraseInfo');
  String checkSeedPhraseSubtile(String index) => Intl.message(
        'What is the $index. word in your seed phrase?',
        name: 'checkSeedPhraseSubtile',
        args: [index],
      );
  String checkSeedPhraseHint(String index) => Intl.message(
        'Enter the $index. word',
        name: 'checkSeedPhraseHint',
        args: [index],
      );
  String get checkSeedPhraseButton1 =>
      Intl.message("CONTINUE", name: 'checkSeedPhraseButton1');
  String get checkSeedPhraseButton2 =>
      Intl.message("GO BACK AND CHECK AGAIN", name: 'checkSeedPhraseButton2');
  String get takerpaymentsID =>
      Intl.message("Taker Payment ID", name: 'takerpaymentsID');
  String get makerpaymentID =>
      Intl.message("Maker Payment ID", name: 'makerpaymentID');
  String get activateAccessBiometric =>
      Intl.message("Activate Biometric protection",
          name: 'activateAccessBiometric');
  String get allowCustomSeed =>
      Intl.message("Allow custom seed", name: 'allowCustomSeed');
  String get hintEnterPassword =>
      Intl.message("Enter your password", name: 'hintEnterPassword');
  String get signInWithSeedPhrase =>
      Intl.message("Sign in with seed phrase", name: 'signInWithSeedPhrase');
  String get signInWithPassword =>
      Intl.message("Sign in with password", name: 'signInWithPassword');
  String get hintEnterSeedPhrase =>
      Intl.message("Enter your seed phrase", name: 'hintEnterSeedPhrase');
  String get wrongPassword =>
      Intl.message("The passwords do not match. Please try again.",
          name: 'wrongPassword');
  String get hintNameYourWallet =>
      Intl.message("Name your wallet", name: 'hintNameYourWallet');
  String get infoWalletPassword => Intl.message(
      "You can choose to encrypt your wallet with a password. If you choose not to use a password, you will need to enter your seed every time you want to access your wallet.",
      name: 'infoWalletPassword');
  String get confirmPassword =>
      Intl.message("Confirm password", name: 'confirmPassword');
  String get dontWantPassword =>
      Intl.message("I don't want a password", name: 'dontWantPassword');
  String get areYouSure => Intl.message("ARE YOU SURE?", name: 'areYouSure');
  String get infoPasswordDialog => Intl.message(
      "If you do not enter a password, you will need to enter your seed phrase every time you want to access your wallet.",
      name: 'infoPasswordDialog');
  String get setUpPassword =>
      Intl.message("SET UP A PASSWORD", name: 'setUpPassword');
  String get createAWallet =>
      Intl.message("CREATE A WALLET", name: 'createAWallet');
  String get restoreWallet => Intl.message("RESTORE", name: 'restoreWallet');
  String get hintPassword => Intl.message("Password", name: 'hintPassword');
  String get hintConfirmPassword =>
      Intl.message("Confirm Password", name: 'hintConfirmPassword');
  String get hintCurrentPassword =>
      Intl.message("Current password", name: 'hintCurrentPassword');
  String get logoutsettings =>
      Intl.message("Log Out Settings", name: 'logoutsettings');
  String get logoutOnExit =>
      Intl.message("Log Out on Exit", name: 'logoutOnExit');
  String get deleteWallet =>
      Intl.message("Delete Wallet", name: 'deleteWallet');
  String get delete => Intl.message("Delete", name: 'delete');
  String get settingDialogSpan1 =>
      Intl.message("Are you sure you want to delete ",
          name: 'settingDialogSpan1');
  String get settingDialogSpan2 =>
      Intl.message(" wallet?", name: 'settingDialogSpan2');
  String get settingDialogSpan3 =>
      Intl.message("If so, make sure you ", name: 'settingDialogSpan3');
  String get settingDialogSpan4 =>
      Intl.message(" record your seed phrase.", name: 'settingDialogSpan4');
  String get settingDialogSpan5 =>
      Intl.message(" In order to restore your wallet in the future.",
          name: 'settingDialogSpan5');
  String get backupTitle => Intl.message("Backup", name: 'backupTitle');
  String get version => Intl.message("version", name: 'verion');
  String get viewSeed => Intl.message("View Seed", name: 'viewSeed');
  String get enterpassword =>
      Intl.message("Please enter your password to continue.",
          name: 'enterpassword');
  String get clipboardCopy =>
      Intl.message("Copy to clipboard", name: 'clipboardCopy');

  String get welcomeTitle => Intl.message("WELCOME", name: 'welcomeTitle');
  String get welcomeName => Intl.message("AtomicDEX", name: 'welcomeName');
  String get welcomeWallet => Intl.message("wallet", name: 'welcomeWallet');
  String get welcomeInfo => Intl.message(
      "AtomicDEX mobile is a next generation multi-coin wallet with native third generation DEX functionality and more.",
      name: 'welcomeInfo');
  String get welcomeLetSetUp =>
      Intl.message("LET'S GET SET UP!", name: 'welcomeLetSetUp');
  String get unlock => Intl.message("unlock", name: 'unlock');
  String noOrder(String coinName) => Intl.message(
        'No $coinName orders available - please try again later, or create an order.',
        name: 'noOrder',
        args: [coinName],
      );
  String get bestAvailableRate =>
      Intl.message("Best available rate", name: 'bestAvailableRate');
  String get receiveLower => Intl.message("Receive", name: 'receiveLower');
  String get makeAorder => Intl.message("make an order", name: 'makeAorder');
  String get exchangeTitle => Intl.message("EXCHANGE", name: 'exchangeTitle');
  String get orders => Intl.message("orders", name: 'orders');
  String get selectCoin => Intl.message("Select coin", name: 'selectCoin');
  String get noFunds => Intl.message("No funds", name: 'noFunds');
  String get noFundsDetected =>
      Intl.message("No funds available - please deposit.",
          name: 'noFundsDetected');
  String get goToPorfolio =>
      Intl.message("Go to portfolio", name: 'goToPorfolio');
  String get noOrderAvailable =>
      Intl.message("Click to create an order", name: 'noOrderAvailable');
  String get orderCreated =>
      Intl.message("Order created", name: 'orderCreated');
  String get orderCreatedInfo =>
      Intl.message("Order succsessfully created", name: 'orderCreatedInfo');
  String get showMyOrders =>
      Intl.message("SHOW MY ORDERS", name: 'showMyOrders');
  String minValue(String coinName, double number) => Intl.message(
        'The minimun amount to sell is ${number.toString()} $coinName',
        name: 'minValue',
        args: [coinName, number],
      );
  String minValueBuy(String coinName, double number) => Intl.message(
        'The minimun amount to buy is ${number.toString()} $coinName',
        name: 'minValue',
        args: [coinName, number],
      );
  String get encryptingWallet =>
      Intl.message("Encrypting wallet", name: 'encryptingWallet');
  String get decryptingWallet =>
      Intl.message("Decrypting wallet", name: 'decryptingWallet');
  String get notEnoughtBalanceForFee =>
      Intl.message("Not enough balance for fees - trade a smaller amount", name: 'notEnoughtBalanceForFee');
  String get noInternet =>
      Intl.message("No Internet Connection", name: 'noInternet');
     
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
