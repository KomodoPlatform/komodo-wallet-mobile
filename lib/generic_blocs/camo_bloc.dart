import 'dart:async';
import 'dart:convert';

import '../model/wallet_security_settings_provider.dart';
import '../model/balance.dart';
import '../utils/encryption_tool.dart';
import '../utils/utils.dart';
import '../utils/log.dart';
import '../widgets/bloc_provider.dart';
import '../model/transaction_data.dart';

CamoBloc camoBloc = CamoBloc();

class CamoBloc implements GenericBlocBase {
  Future<void> init() => _loadPrefs();

  Future<void> _loadPrefs() async {
    _isCamoEnabled =
        walletSecuritySettingsProvider.enableCamo ?? _isCamoEnabled;
    _isCamoActive =
        walletSecuritySettingsProvider.isCamoActive ?? _isCamoActive;
    _camoFraction =
        walletSecuritySettingsProvider.camoFraction ?? _camoFraction;
    _sessionStartedAt = walletSecuritySettingsProvider.camoSessionStartedAt ??
        _sessionStartedAt;
    getCamoPinValue();
  }

  bool _isCamoActive = false;
  bool _isCamoEnabled = false;
  int _camoFraction = 10; // % of real balance
  int _sessionStartedAt; // milliseconds since Epoch
  bool shouldWarnBadCamoPin = false;
  String _camoPinValue;

  final StreamController<bool> _isCamoActiveController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsCamoActive => _isCamoActiveController.sink;
  Stream<bool> get outIsCamoActive => _isCamoActiveController.stream;

  final StreamController<bool> _isCamoEnabledController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inCamoEnabled => _isCamoEnabledController.sink;
  Stream<bool> get outCamoEnabled => _isCamoEnabledController.stream;

  final StreamController<int> _camoFractionController =
      StreamController<int>.broadcast();
  Sink<int> get _inCamoFraction => _camoFractionController.sink;
  Stream<int> get outCamoFraction => _camoFractionController.stream;

  final StreamController<String> _camoPinValueController =
      StreamController<String>.broadcast();
  Sink<String> get _inCamoPinValue => _camoPinValueController.sink;
  Stream<String> get outCamoPinValue => _camoPinValueController.stream;

  @override
  void dispose() {
    _isCamoActiveController?.close();
    _isCamoEnabledController?.close();
    _camoFractionController?.close();
    _camoPinValueController?.close();
  }

  void camouflageBalance(Balance balance) {
    final String balanceStr = walletSecuritySettingsProvider.camoBalance;
    dynamic json;
    try {
      json = jsonDecode(balanceStr);
    } catch (e) {
      json = <String, String>{};
    }

    double fakeBalance;
    if (json[balance.coin] == null) {
      json[balance.coin] = balance.balance.toString();
      walletSecuritySettingsProvider.camoBalance = jsonEncode(json);
      fakeBalance = balance.balance.toDouble() * _camoFraction / 100;
    } else {
      final double balanceDelta =
          double.parse(json[balance.coin]) - balance.balance.toDouble();
      fakeBalance =
          double.parse(json[balance.coin]) * _camoFraction / 100 - balanceDelta;
    }

    if (fakeBalance < 0) fakeBalance = 0;
    balance.balance = deci(fakeBalance);
  }

  void camouflageTransaction(Transaction transaction) {
    if (_isNewTransaction(transaction)) return;

    if (transaction.spentByMe.isNotEmpty) {
      transaction.spentByMe =
          (double.parse(transaction.spentByMe) * _camoFraction / 100)
              .toString();
    }

    if (transaction.receivedByMe.isNotEmpty) {
      transaction.receivedByMe =
          (double.parse(transaction.receivedByMe) * _camoFraction / 100)
              .toString();
    }

    if (transaction.myBalanceChange.isNotEmpty) {
      transaction.myBalanceChange =
          (double.parse(transaction.myBalanceChange) * _camoFraction / 100)
              .toString();
    }
  }

  bool _isNewTransaction(Transaction transaction) {
    if (transaction.timestamp == 0) return true;
    if (transaction.timestamp * 1000 > _sessionStartedAt) return true;

    return false;
  }

  bool get isCamoActive => _isCamoActive;
  set isCamoActive(bool val) {
    if (val == _isCamoActive) return;

    _isCamoActive = val;
    _inIsCamoActive.add(val);
    Log('authenticate_bloc', 'switchCamoActive] Camouflage mode set to $val');

    walletSecuritySettingsProvider.isCamoActive = val;

    if (val) {
      _sessionStartedAt = DateTime.now().millisecondsSinceEpoch;
      walletSecuritySettingsProvider.enableCamo = true;
      walletSecuritySettingsProvider.camoSessionStartedAt = _sessionStartedAt;
      walletSecuritySettingsProvider.camoBalance = null;
    }
  }

  bool get isCamoEnabled => _isCamoEnabled;
  set isCamoEnabled(bool val) {
    _isCamoEnabled = val;
    _inCamoEnabled.add(val);
    walletSecuritySettingsProvider.enableCamo = val;
  }

  int get camoFraction => _camoFraction;
  set camoFraction(int val) {
    _camoFraction = val;
    _inCamoFraction.add(val);
    walletSecuritySettingsProvider.camoFraction = val;
  }

  String get camoPinValue => _camoPinValue;

  Future<void> getCamoPinValue() async {
    final camoPin = await EncryptionTool().read('camoPin');
    _camoPinValue = camoPin;
    _inCamoPinValue.add(camoPin);
  }
}
