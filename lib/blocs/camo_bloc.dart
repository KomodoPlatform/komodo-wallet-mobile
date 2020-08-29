import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

CamoBloc camoBloc = CamoBloc();

class CamoBloc implements BlocBase {
  CamoBloc() {
    _loadPrefs();
  }

  SharedPreferences _prefs;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    _isCamoEnabled = _prefs.getBool('isCamoEnabled') ?? _isCamoEnabled;
    _camoFraction = _prefs.getInt('camoFraction') ?? _camoFraction;
  }

  bool _isCamoActive = false;
  bool _isCamoEnabled = false;
  int _camoFraction = 10; // % of real balance
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

  bool get isCamoActive => _isCamoActive;
  set isCamoActive(bool val) {
    _isCamoActive = val;
    _inIsCamoActive.add(val);
    Log('authenticate_bloc', 'switchCamoActive] Camouflage mode set to $val');
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
