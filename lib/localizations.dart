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
      Intl.message("Not enough balance for fees - trade a smaller amount",
          name: 'notEnoughtBalanceForFee');
  String get noInternet =>
      Intl.message("No Internet Connection", name: 'noInternet');
  String get legalTitle => Intl.message("Legal", name: 'legalTitle');
  String get disclaimerAndTos =>
      Intl.message("Disclaimer & ToS", name: 'disclaimerAndTos');
  String get accepteula =>
      Intl.message("Accept EULA", name: 'accepteula');
  String get accepttac =>
      Intl.message("Accept TERMS and CONDITIONS", name: 'accepttac');
  String get confirmeula =>
      Intl.message("By clicking the below buttons you confirm to have read the \"EULA\" and \"Terms and Conditions\" and accept these", name: 'confirmeula');

  String get eulaTitle1 =>
      Intl.message("End-User License Agreement (EULA) of atomicDEX mobile:\n\n", name: 'eulaTitle1');
  String get eulaTitle2 =>
      Intl.message("TERMS and CONDITIONS: (APPLICATION USER AGREEMENT)\n\n", name: 'eulaTitle2');
  String get eulaTitle3 =>
      Intl.message("TERMS AND CONDITIONS OF USE AND DISCLAIMER\n\n", name: 'eulaTitle3');
  String get eulaTitle4 =>
      Intl.message("GENERAL USE\n\n", name: 'eulaTitle4');
  String get eulaTitle5 =>
      Intl.message("MODIFICATIONS\n\n", name: 'eulaTitle5');
  String get eulaTitle6 =>
      Intl.message("LIMITATIONS ON USE\n\n", name: 'eulaTitle6');
  String get eulaTitle7 =>
      Intl.message("Accounts and membership\n\n", name: 'eulaTitle7');
  String get eulaTitle8 =>
      Intl.message("Backups\n\n", name: 'eulaTitle8');
  String get eulaTitle9 =>
      Intl.message("GENERAL WARNING\n\n", name: 'eulaTitle9');
  String get eulaTitle10 =>
      Intl.message("ACCESS AND SECURITY\n\n", name: 'eulaTitle10');
  String get eulaTitle11 =>
      Intl.message("INTELLECTUAL PROPERTY RIGHTS\n\n", name: 'eulaTitle11');
  String get eulaTitle12 =>
      Intl.message("DISCLAIMER\n\n", name: 'eulaTitle12');
  String get eulaTitle13 =>
      Intl.message("REPRESENTATIONS AND WARRANTIES, INDEMNIFICATION, AND LIMITATION OF LIABILITY\n\n", name: 'eulaTitle13');
  String get eulaTitle14 =>
      Intl.message("GENERAL RISK FACTORS\n\n", name: 'eulaTitle14');
  String get eulaTitle15 =>
      Intl.message("INDEMNIFICATION\n\n", name: 'eulaTitle15');
  String get eulaTitle16 =>
      Intl.message("RISK DISCLOSURES RELATING TO THE WALLET\n\n", name: 'eulaTitle16');
  String get eulaTitle17 =>
      Intl.message("NO INVESTMENT ADVICE OR BROKERAGE\n\n", name: 'eulaTitle17');
  String get eulaTitle18 =>
      Intl.message("TERMINATION\n\n", name: 'eulaTitle18');
  String get eulaTitle19 =>
      Intl.message("THIRD PARTY RIGHTS\n\n", name: 'eulaTitle19');
  String get eulaTitle20 =>
      Intl.message("OUR LEGAL OBLIGATIONS\n\n", name: 'eulaTitle20');
      
  String get eulaParagraphe1 =>
      Intl.message("This End-User License Agreement (\"EULA\") is a legal agreement between you and Komodo Platform.\n\nThis EULA agreement governs your acquisition and use of our atomicDEX mobile software (\"Software\", \"Mobile Application\", \"Application\" or \"App\") directly from Komodo Platform or indirectly through a Komodo Platform authorized entity, reseller or distributor (a \"Distributor\").\nPlease read this EULA agreement carefully before completing the installation process and using the atomicDEX mobile software. It provides a license to use the atomicDEX mobile software and contains warranty information and liability disclaimers.\nIf you register for the beta program of the atomicDEX mobile software, this EULA agreement will also govern that trial. By clicking \"accept\" or installing and/or using the atomicDEX mobile software, you are confirming your acceptance of the Software and agreeing to become bound by the terms of this EULA agreement.\nIf you are entering into this EULA agreement on behalf of a company or other legal entity, you represent that you have the authority to bind such entity and its affiliates to these terms and conditions. If you do not have such authority or if you do not agree with the terms and conditions of this EULA agreement, do not install or use the Software, and you must not accept this EULA agreement.\nThis EULA agreement shall apply only to the Software supplied by Komodo Platform herewith regardless of whether other software is referred to or described herein. The terms also apply to any Komodo Platform updates, supplements, Internet-based services, and support services for the Software, unless other terms accompany those items on delivery. If so, those terms apply.\nLicense Grant\nKomodo Platform hereby grants you a personal, non-transferable, non-exclusive licence to use the atomicDEX mobile software on your devices in accordance with the terms of this EULA agreement.\n\nYou are permitted to load the atomicDEX mobile software (for example a PC, laptop, mobile or tablet) under your control. You are responsible for ensuring your device meets the minimum security and resource requirements of the atomicDEX mobile software.\nYou are not permitted to:\nEdit, alter, modify, adapt, translate or otherwise change the whole or any part of the Software nor permit the whole or any part of the Software to be combined with or become incorporated in any other software, nor decompile, disassemble or reverse engineer the Software or attempt to do any such things\nReproduce, copy, distribute, resell or otherwise use the Software for any commercial purpose\nUse the Software in any way which breaches any applicable local, national or international law\nuse the Software for any purpose that Komodo Platform considers is a breach of this EULA agreement\nIntellectual Property and Ownership\nKomodo Platform shall at all times retain ownership of the Software as originally downloaded by you and all subsequent downloads of the Software by you. The Software (and the copyright, and other intellectual property rights of whatever nature in the Software, including any modifications made thereto) are and shall remain the property of Komodo Platform.\n\nKomodo Platform reserves the right to grant licences to use the Software to third parties.\nTermination\nThis EULA agreement is effective from the date you first use the Software and shall continue until terminated. You may terminate it at any time upon written notice to Komodo Platform.\nIt will also terminate immediately if you fail to comply with any term of this EULA agreement. Upon such termination, the licenses granted by this EULA agreement will immediately terminate and you agree to stop all access and use of the Software. The provisions that by their nature continue and survive will survive any termination of this EULA agreement.\nGoverning Law\nThis EULA agreement, and any dispute arising out of or in connection with this EULA agreement, shall be governed by and construed in accordance with the laws of Vietnam.\n\nThis document was last updated on July 3, 2019\n\n", name: 'eulaParagraphe1');
  String get eulaParagraphe2 =>
      Intl.message("This disclaimer applies to the contents and services of the app AtomicDEX and is valid for all users of the “Application” (\"Software\", “Mobile Application”, “Application” or “App”).\n\nThe Application is owned by Komodo Platform.\n\nWe reserve the right to amend the following Terms and Conditions (governing the use of the application “atomicDEX mobile”) at any time without prior notice and at our sole discretion. It is your responsibility to periodically check this Terms and Conditions for any updates to these Terms, which shall come into force once published.\nYour continued use of the application shall be deemed as acceptance of the following Terms. \nWe are a company incorporated in Vietnam and these Terms and Conditions are governed by and subject to the laws of Vietnam. \nIf You do not agree with these Terms and Conditions, You must not use or access this software.\n\n", name: 'eulaParagraphe2');
  String get eulaParagraphe3 =>
      Intl.message("By entering into this User (each subject accessing or using the site) Agreement (this writing) You declare that You are an individual over the age of majority (at least 18 or older) and have the capacity to enter into this User Agreement and accept to be legally bound by the terms and conditions of this User Agreement, as incorporated herein and amended from time to time. \nIn order to use the Services provided by Komodo Platform, You may be required to provide certain identification details pursuant to our know-your-customer and anti-money laundering compliance program.\n\n", name: 'eulaParagraphe3');
  String get eulaParagraphe4 =>
      Intl.message("We may change the terms of this User Agreement at any time. Any such changes will take effect when published in the application, or when You use the Services.\n\n\nRead the User Agreement carefully every time You use our Services. Your continued use of the Services shall signify your acceptance to be bound by the current User Agreement. Our failure or delay in enforcing or partially enforcing any provision of this User Agreement shall not be construed as a waiver of any.\n\n", name: 'eulaParagraphe4');
  String get eulaParagraphe5 =>
      Intl.message("You are not allowed to decompile, decode, disassemble, rent, lease, loan, sell, sublicense, or create derivative works from the atomicDEX mobile application or the user content. Nor are You allowed to use any network monitoring or detection software to determine the software architecture, or extract information about usage or individuals’ or users’ identities. \nYou are not allowed to copy, modify, reproduce, republish, distribute, display, or transmit for commercial, non-profit or public purposes all or any portion of the application or the user content without our prior written authorization.\n\n", name: 'eulaParagraphe5');
  String get eulaParagraphe6 =>
      Intl.message("If you create an account in the Mobile Application, you are responsible for maintaining the security of your account and you are fully responsible for all activities that occur under the account and any other actions taken in connection with it. You must immediately notify us of any unauthorized uses of your account or any other breaches of security. We will not be liable for any acts or omissions by you, including any damages of any kind incurred as a result of such acts or omissions.\n\n", name: 'eulaParagraphe6');
  String get eulaParagraphe7 =>
      Intl.message("We are not responsible for seed-phrases residing in the Mobile Application. In no event shall we be held liable for any loss of any kind. It is your sole responsibility to maintain appropriate backup of your accounts/seedphrases.\n\n", name: 'eulaParagraphe7');
  String get eulaParagraphe8 =>
      Intl.message("You should not act, or refrain from acting solely on the basis of the content of this application. \nYour access to this application does not itself create an adviser-client relationship between You and us. \nThe content of this application does not constitute a solicitation or inducement to invest in any financial products or services offered by us. \nAny advice included in this application has been prepared without taking into account your objectives, financial situation or needs. You should consider our Risk Disclosure Notice before making any decision on whether to acquire the product described in that document.\n\n", name: 'eulaParagraphe8');
  String get eulaParagraphe9 =>
      Intl.message("We do not guarantee your continuous access to the application or that your access or use will be error-free. \nWe will not be liable in the event that the application is unavailable to You for any reason (for example, due to computer downtime ascribable to malfunctions, upgrades, server problems, precautionary or corrective maintenance activities or interruption in telecommunication supplies). \n\nWe reserve the right at any time to: \n- deny or terminate all or part of your access to the application whereas in our opinion, there are concerns regarding unreasonable use, security issues or unauthorised access or You have breached any of these Terms;\n- block or suspend – in full or partially - your account, remove your default settings, or part thereof, without prior notice to You.\n\n\n", name: 'eulaParagraphe9');
  String get eulaParagraphe10 =>
      Intl.message("Komodo Platform is the owner and/or authorised user of all trademarks, service marks, design marks, patents, copyrights, database rights and all other intellectual property appearing on or contained within the application, unless otherwise indicated. All information, text, material, graphics, software and advertisements on the application interface are copyright of Komodo Platform, its suppliers and licensors, unless otherwise expressly indicated by Komodo Platform. \nExcept as provided in the Terms, use of the application does not grant You any right, title, interest or license to any such intellectual property You may have access to on the application. \nWe own the rights, or have permission to use, the trademarks listed in our application. You are not authorised to use any of those trademarks without our written authorization – doing so would constitute a breach of our or another party’s intellectual property rights. \nAlternatively, we might authorise You to use the content in our application if You previously contact us and we agree in writing.\n\n", name: 'eulaParagraphe10');
  String get eulaParagraphe11 =>
      Intl.message("Komodo Platform cannot guarantee the safety or security of your computer systems. We do not accept liability for any loss or corruption of electronically stored data or any damage to any computer system occurred in connection with the use of the application or of the user content.\nKomodo Platform makes no representation or warranty of any kind, express or implied, as to the operation of the application or the user content. You expressly agree that your use of the application is entirely at your sole risk.\nYou agree that the content provided in the application and the user content do not constitute financial product, legal or taxation advice, and You agree on not representing the user content or the application as such.\nTo the extent permitted by current legislation, the application is provided on an “as is, as available” basis.\n\nKomodo Platform expressly disclaims all responsibility for any loss, injury, claim, liability, or damage, or any indirect, incidental, special or consequential damages or loss of profits whatsoever resulting from, arising out of or in any way related to: \n(a) any errors in or omissions of the application and/or the user content, including but not limited to technical inaccuracies and typographical errors; \n(b) any third party website, application or content directly or indirectly accessed through links in the application, including but not limited to any errors or omissions; \n(c) the unavailability of the application or any portion of it; \n(d) your use of the application;\n(e) your use of any equipment or software in connection with the application. \nAny Services offered in connection with the Platform are provided on an \"as is\" basis, without any representation or warranty, whether express, implied or statutory. To the maximum extent permitted by applicable law, we specifically disclaim any implied warranties of title, merchantability, suitability for a particular purpose and/or non-infringement. We do not make any representations or warranties that use of the Platform will be continuous, uninterrupted, timely, or error-free.\nWe make no warranty that any Platform will be free from viruses, malware, or other related harmful material and that your ability to access any Platform will be uninterrupted. Any defects or malfunction in the product should be directed to the third party offering the Platform, not to Komodo. \nWe will not be responsible or liable to You for any loss of any kind, from action taken, or taken in reliance on the material or information contained in or through the Platform.\nThis is experimental and unfinished software. Use at your own risk. No warranty for any kind of damage. By using this application you agree to this terms and conditions.\n\n", name: 'eulaParagraphe11');
  String get eulaParagraphe12 =>
      Intl.message("When accessing or using the Services, You agree that You are solely responsible for your conduct while accessing and using our Services. Without limiting the generality of the foregoing, You agree that You will not:\n(a) Use the Services in any manner that could interfere with, disrupt, negatively affect or inhibit other users from fully enjoying the Services, or that could damage, disable, overburden or impair the functioning of our Services in any manner;\n(b) Use the Services to pay for, support or otherwise engage in any illegal activities, including, but not limited to illegal gambling, fraud, money laundering, or terrorist activities;\n(c) Use any robot, spider, crawler, scraper or other automated means or interface not provided by us to access our Services or to extract data;\n(d) Use or attempt to use another user’s Wallet or credentials without authorization;\n(e) Attempt to circumvent any content filtering techniques we employ, or attempt to access any service or area of our Services that You are not authorized to access;\n(f) Introduce to the Services any virus, Trojan, worms, logic bombs or other harmful material;\n(g) Develop any third-party applications that interact with our Services without our prior written consent;\n(h) Provide false, inaccurate, or misleading information; \n(i) Encourage or induce any other person to engage in any of the activities prohibited under this Section.\n\n\n", name: 'eulaParagraphe12');
  String get eulaParagraphe13 =>
      Intl.message("You agree and understand that there are risks associated with utilizing Services involving Virtual Currencies including, but not limited to, the risk of failure of hardware, software and internet connections, the risk of malicious software introduction, and the risk that third parties may obtain unauthorized access to information stored within your Wallet, including but not limited to your public and private keys. You agree and understand that Komodo Platform will not be responsible for any communication failures, disruptions, errors, distortions or delays You may experience when using the Services, however caused.\nYou accept and acknowledge that there are risks associated with utilizing any virtual currency network, including, but not limited to, the risk of unknown vulnerabilities in or unanticipated changes to the network protocol. You acknowledge and accept that Komodo Platform has no control over any cryptocurrency network and will not be responsible for any harm occurring as a result of such risks, including, but not limited to, the inability to reverse a transaction, and any losses in connection therewith due to erroneous or fraudulent actions.\nThe risk of loss in using Services involving Virtual Currencies may be substantial and losses may occur over a short period of time. In addition, price and liquidity are subject to significant fluctuations that may be unpredictable.\nVirtual Currencies are not legal tender and are not backed by any sovereign government. In addition, the legislative and regulatory landscape around Virtual Currencies is constantly changing and may affect your ability to use, transfer, or exchange Virtual Currencies.\nCFDs are complex instruments and come with a high risk of losing money rapidly due to leverage. 80.6% of retail investor accounts lose money when trading CFDs with this provider. You should consider whether You understand how CFDs work and whether You can afford to take the high risk of losing your money.\n\n", name: 'eulaParagraphe13');
  String get eulaParagraphe14 =>
      Intl.message("You agree to indemnify, defend and hold harmless Komodo Platform, its officers, directors, employees, agents, licensors, suppliers and any third party information providers to the application from and against all losses, expenses, damages and costs, including reasonable lawyer fees, resulting from any violation of the Terms by You.\nYou also agree to indemnify Komodo Platform against any claims that information or material which You have submitted to Komodo Platform is in violation of any law or in breach of any third party rights (including, but not limited to, claims in respect of defamation, invasion of privacy, breach of confidence, infringement of copyright or infringement of any other intellectual property right).\n\n", name: 'eulaParagraphe14');
  String get eulaParagraphe15 =>
      Intl.message("In order to be completed, any Virtual Currency transaction created with the Komodo Platform must be confirmed and recorded in the Virtual Currency ledger associated with the relevant Virtual Currency network. Such networks are decentralized, peer-to-peer networks supported by independent third parties, which are not owned, controlled or operated by Komodo Platform.\nKomodo Platform has no control over any Virtual Currency network and therefore cannot and does not ensure that any transaction details You submit via our Services will be confirmed on the relevant Virtual Currency network. You agree and understand that the transaction details You submit via our Services may not be completed, or may be substantially delayed, by the Virtual Currency network used to process the transaction. We do not guarantee that the Wallet can transfer title or right in any Virtual Currency or make any warranties whatsoever with regard to title.\nOnce transaction details have been submitted to a Virtual Currency network, we cannot assist You to cancel or otherwise modify your transaction or transaction details. Komodo Platform has no control over any Virtual Currency network and does not have the ability to facilitate any cancellation or modification requests.\nIn the event of a Fork, Komodo Platform may not be able to support activity related to your Virtual Currency. You agree and understand that, in the event of a Fork, the transactions may not be completed, completed partially, incorrectly completed, or substantially delayed. Komodo Platform is not responsible for any loss incurred by You caused in whole or in part, directly or indirectly, by a Fork.\nIn no event shall Komodo Platform, its affiliates and service providers, or any of their respective officers, directors, agents, employees or representatives, be liable for any lost profits or any special, incidental, indirect, intangible, or consequential damages, whether based on contract, tort, negligence, strict liability, or otherwise, arising out of or in connection with authorized or unauthorized use of the services, or this agreement, even if an authorized representative of Komodo Platform has been advised of, has known of, or should have known of the possibility of such damages. \nFor example (and without limiting the scope of the preceding sentence), You may not recover for lost profits, lost business opportunities, or other types of special, incidental, indirect, intangible, or consequential damages. Some jurisdictions do not allow the exclusion or limitation of incidental or consequential damages, so the above limitation may not apply to You. \nWe will not be responsible or liable to You for any loss and take no responsibility for damages or claims arising in whole or in part, directly or indirectly from: (a) user error such as forgotten passwords, incorrectly constructed transactions, or mistyped Virtual Currency addresses; (b) server failure or data loss; (c) corrupted or otherwise non-performing Wallets or Wallet files; (d) unauthorized access to applications; (e) any unauthorized activities, including without limitation the use of hacking, viruses, phishing, brute forcing or other means of attack against the Services.\n\n", name: 'eulaParagraphe15');
  String get eulaParagraphe16 =>
      Intl.message("For the avoidance of doubt, Komodo Platform does not provide investment, tax or legal advice, nor does Komodo Platform broker trades on your behalf. All Komodo Platform trades are executed automatically, based on the parameters of your order instructions and in accordance with posted Trade execution procedures, and You are solely responsible for determining whether any investment, investment strategy or related transaction is appropriate for You based on your personal investment objectives, financial circumstances and risk tolerance. You should consult your legal or tax professional regarding your specific situation.\Neither Komodo nor its owners, members, officers, directors, partners, consultants, nor anyone involved in the publication of this application, is a registered investment adviser or broker-dealer or associated person with a registered investment adviser or broker-dealer and none of the foregoing make any recommendation that the purchase or sale of crypto-assets or securities of any company profiled in the mobile Application is suitable or advisable for any person or that an investment or transaction in such crypto-assets or securities will be profitable. \The information contained in the mobile Application is not intended to be, and shall not constitute, an offer to sell or the solicitation of any offer to buy any crypto-asset or security. \The information presented in the mobile Application is provided for informational purposes only and is not to be treated as advice or a recommendation to make any specific investment or transaction. \Please, consult with a qualified professional before making any decisions.\The opinions and analysis included in this applications are based on information from sources deemed to be reliable and are provided “as is” in good faith. Komodo makes no representation or warranty, expressed, implied, or statutory, as to the accuracy or completeness of such information, which may be subject to change without notice. Komodo shall not be liable for any errors or any actions taken in relation to the above. Statements of opinion and belief are those of the authors and/or editors who contribute to this application, and are based solely upon the information possessed by such authors and/or editors. \No inference should be drawn that Komodo or such authors or editors have any special or greater knowledge about the crypto-assets or companies profiled or any particular expertise in the industries or markets in which the profiled crypto-assets and companies operate and compete.\Information on this application is obtained from sources deemed to be reliable; however, Komodo takes no responsibility for verifying the accuracy of such information and makes no representation that such information is accurate or complete. \Certain statements included in this application may be forward-looking statements based on current expectations. Komodo makes no representation and provides no assurance or guarantee that such forward-looking statements will prove to be accurate.\Persons using the Komodo application are urged to consult with a qualified professional with respect to an investment or transaction in any crypto-asset or company profiled herein. \Additionally, persons using this application expressly represent that the content in this application is not and will not be a consideration in such persons’ investment or transaction decisions. Traders should verify independently information provided in the Komodo application by completing their own due diligence on any crypto-asset or company in which they are contemplating an investment or transaction of any kind and review a complete information package on that crypto-asset or company, which should include, but not be limited to, related blog updates and press releases.\Past performance of profiled crypto-assets and securities is not indicative of future results. \Crypto-assets and companies profiled on this site may lack an active trading market and invest in a crypto-asset or security that lacks an active trading market or trade on certain media, platforms and markets are deemed highly speculative and carry a high degree of risk. Anyone holding such crypto-assets and securities should be financially able and prepared to bear the risk of loss and the actual loss of his or her entire trade. The information in this application is not designed to be used as a basis for an investment decision. \Persons using the Komodo application should confirm to their own satisfaction the veracity of any information prior to entering into any investment or making any transaction. The decision to buy or sell any crypto-asset or security that may be featured by Komodo is done purely and entirely at the reader’s own risk. \As a reader and user of this application, You agree that under no circumstances will You seek to hold liable owners, members, officers, directors, partners, consultants or other persons involved in the publication of this application for any losses incurred by the use of information contained in this application\Komodo and its contractors and affiliates may profit in the event the crypto-assets and securities increase or decrease in value. Such crypto-assets and securities may be bought or sold from time to time, even after Komodo has distributed positive information regarding the crypto-assets and companies. \Komodo has no obligation to inform readers of its trading activities or the trading activities of any of its owners, members, officers, directors, contractors and affiliates and/or any companies affiliated with BC Relations’ owners, members, officers, directors, contractors and affiliates.\Komodo and its affiliates may from time to time enter into agreements to purchase crypto-assets or securities to provide a method to reach their goals.\n\n", name: 'eulaParagraphe16');
  String get eulaParagraphe17 =>
      Intl.message("The Terms are effective until terminated by Komodo Platform. \nIn the event of termination, You are no longer authorized to access the Application, but all restrictions imposed on You and the disclaimers and limitations of liability set out in the Terms will survive termination. \nSuch termination shall not affect any legal right that may have accrued to Komodo Platform against You up to the date of termination. \nKomodo Platform may also remove the Application as a whole or any sections or features of the Application at any time. \n\n", name: 'eulaParagraphe17');
  String get eulaParagraphe18 =>
      Intl.message("The provisions of previous paragraphs are for the benefit of Komodo Platform and its officers, directors, employees, agents, licensors, suppliers, and any third party information providers to the Application. Each of these individuals or entities shall have the right to assert and enforce those provisions directly against You on its own behalf.\n\n", name: 'eulaParagraphe18');
  String get eulaParagraphe19 =>
      Intl.message("We might be required to retain and use personal data to meet our internal and external audit requirements, for data security purposes and as we believe to be necessary or appropriate: \n(a) to comply with our obligations under applicable law and regulations, which may include laws and regulations outside your country of residence;\n(b) to respond to requests from courts, law enforcement agencies, regulatory agencies, and other public and government authorities, which may include such authorities outside your country of residence; \n(c) to monitor compliance with and enforce our Platform terms and conditions;\n(d) to carry out anti-money laundering, sanctions or Know Your Customer checks as required by applicable laws and regulations; \n(e) to protect our rights, privacy, safety, property, or those of other persons. We may also be required to use and retain personal data after You have closed your account for legal, regulatory and compliance reasons, such as the prevention, detection or investigation of a crime; loss prevention; or fraud prevention. \nWe also collect and process non-personal, anonymized data for statistical purposes and analysis and to help us provide a better service.\n\nThis document was last updated on July 3, 2019\n\n", name: 'eulaParagraphe19');
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
