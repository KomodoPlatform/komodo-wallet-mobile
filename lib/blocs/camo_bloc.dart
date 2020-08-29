import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

CamoBloc camoBloc = CamoBloc();

class CamoBloc implements BlocBase {
  Future<void> init() => _loadPrefs();

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    _isCamoEnabled = _prefs.getBool('isCamoEnabled') ?? _isCamoEnabled;
    _isCamoActive = _prefs.getBool('isCamoActive') ?? _isCamoActive;
    _camoFraction = _prefs.getInt('camoFraction') ?? _camoFraction;
    _sessionStartedAt =
        _prefs.getInt('camoSessionStartedAt') ?? _sessionStartedAt;
  }

  SharedPreferences _prefs;

  bool _isCamoActive = false;
  bool _isCamoEnabled = false;
  int _camoFraction = 10; // % of real balance
  int _sessionStartedAt; // milliseconds since Epoch
  bool shouldWarnBadCamoPin = false;

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

  @override
  void dispose() {
    _isCamoActiveController?.close();
    _isCamoEnabledController?.close();
    _camoFractionController?.close();
  }

  void camouflageBalance(Balance balance) {
    final String balanceStr = _prefs.getString('camoBalance');
    dynamic json;
    try {
      json = jsonDecode(balanceStr);
    } catch (e) {
      json = <String, String>{};
    }

    double fakeBalance;
    if (json[balance.coin] == null) {
      json[balance.coin] = balance.balance.toString();
      _prefs.setString('camoBalance', jsonEncode(json));
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

  bool get isCamoActive => _isCamoActive;
  set isCamoActive(bool val) {
    if (val == _isCamoActive) return;

    _isCamoActive = val;
    _inIsCamoActive.add(val);
    Log('authenticate_bloc', 'switchCamoActive] Camouflage mode set to $val');

    _prefs.setBool('isCamoActive', val);

    if (val) {
      _sessionStartedAt = DateTime.now().millisecondsSinceEpoch;
      _prefs.setInt('camoSessionStartedAt', _sessionStartedAt);
      _prefs.remove('camoBalance');
    }
  }

  bool get isCamoEnabled => _isCamoEnabled;
  set isCamoEnabled(bool val) {
    _isCamoEnabled = val;
    _inCamoEnabled.add(val);
    _prefs.setBool('isCamoEnabled', val);
  }

  int get camoFraction => _camoFraction;
  set camoFraction(int val) {
    _camoFraction = val;
    _inCamoFraction.add(val);
    _prefs.setInt('camoFraction', val);
  }
}
