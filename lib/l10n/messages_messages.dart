// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'messages';

  static m0(name) => "Added ${name} successfully !";

  static m1(assets) => "${assets} Assets";

  static m2(coinName, address) => "My ${coinName} address: \n${address}";

  static m4(amount, coinName) => "WITHDRAW ${amount} ${coinName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "activateAccessPin" : MessageLookupByLibrary.simpleMessage("Activate PIN access"),
    "addCoin" : MessageLookupByLibrary.simpleMessage("Add coin"),
    "addingCoinSuccess" : m0,
    "addressSend" : MessageLookupByLibrary.simpleMessage("Address To Send"),
    "allCard" : MessageLookupByLibrary.simpleMessage("All >"),
    "amount" : MessageLookupByLibrary.simpleMessage("Amount"),
    "amountToSell" : MessageLookupByLibrary.simpleMessage("Amount To Sell"),
    "buy" : MessageLookupByLibrary.simpleMessage("Buy"),
    "buySuccessWaiting" : MessageLookupByLibrary.simpleMessage("Order matched, please wait"),
    "changePin" : MessageLookupByLibrary.simpleMessage("Change PIN"),
    "checkOut" : MessageLookupByLibrary.simpleMessage("Check Out"),
    "close" : MessageLookupByLibrary.simpleMessage("Close"),
    "code" : MessageLookupByLibrary.simpleMessage("Code: "),
    "comingSoon" : MessageLookupByLibrary.simpleMessage("Coming soon..."),
    "commissionFee" : MessageLookupByLibrary.simpleMessage("commission fee"),
    "confirm" : MessageLookupByLibrary.simpleMessage("confirm"),
    "confirmPin" : MessageLookupByLibrary.simpleMessage("Confirm PIN"),
    "confirmSeed" : MessageLookupByLibrary.simpleMessage("Confirm Seed"),
    "createPin" : MessageLookupByLibrary.simpleMessage("Create PIN"),
    "enterPinCode" : MessageLookupByLibrary.simpleMessage("Enter your PIN code"),
    "enterSeedPhrase" : MessageLookupByLibrary.simpleMessage("Enter Your Seed Phrase"),
    "errorTryAgain" : MessageLookupByLibrary.simpleMessage("Error, please try again"),
    "errorTryLater" : MessageLookupByLibrary.simpleMessage("Error, please try later."),
    "errorValueEmpty" : MessageLookupByLibrary.simpleMessage("Value is too high or low"),
    "estimateValue" : MessageLookupByLibrary.simpleMessage("Estimated Total Value"),
    "exampleHintSeed" : MessageLookupByLibrary.simpleMessage("Example: over cake age ..."),
    "getBackupPhrase" : MessageLookupByLibrary.simpleMessage("Important: please back up your seed phrase now!"),
    "lockScreen" : MessageLookupByLibrary.simpleMessage("Lock Screen"),
    "login" : MessageLookupByLibrary.simpleMessage("login"),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "marketplace" : MessageLookupByLibrary.simpleMessage("Marketplace"),
    "max" : MessageLookupByLibrary.simpleMessage("MAX"),
    "networkFee" : MessageLookupByLibrary.simpleMessage("Network fee"),
    "newAccount" : MessageLookupByLibrary.simpleMessage("new account"),
    "newAccountUpper" : MessageLookupByLibrary.simpleMessage("New Account"),
    "next" : MessageLookupByLibrary.simpleMessage("next"),
    "numberAssets" : m1,
    "paidWith" : MessageLookupByLibrary.simpleMessage("Paid with "),
    "placeOrder" : MessageLookupByLibrary.simpleMessage("Place your order"),
    "portfolio" : MessageLookupByLibrary.simpleMessage("portfolio"),
    "recommendSeedMessage" : MessageLookupByLibrary.simpleMessage("We recommend storing it offline."),
    "security" : MessageLookupByLibrary.simpleMessage("Security"),
    "seedPhraseTitle" : MessageLookupByLibrary.simpleMessage("Seed Phrase for Your Portfolio"),
    "selectCoinToBuy" : MessageLookupByLibrary.simpleMessage("Select the coin you want to BUY"),
    "selectCoinToSell" : MessageLookupByLibrary.simpleMessage("Select the coin you want to SELL"),
    "selectPaymentMethod" : MessageLookupByLibrary.simpleMessage("Select Your Payment Method"),
    "sell" : MessageLookupByLibrary.simpleMessage("Sell"),
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "shareAddress" : m2,
    "swap" : MessageLookupByLibrary.simpleMessage("swap"),
    "value" : MessageLookupByLibrary.simpleMessage("Value: "),
    "volumes" : MessageLookupByLibrary.simpleMessage("Volumes"),
    "withdraw" : MessageLookupByLibrary.simpleMessage("Withdraw"),
    "withdrawConfirm" : MessageLookupByLibrary.simpleMessage("Withdraw confirm"),
    "withdrawValue" : m4,
    "youAreSending" : MessageLookupByLibrary.simpleMessage("You are sending"),
    "youWillReceived" : MessageLookupByLibrary.simpleMessage("You will receive: "),
  };
}
