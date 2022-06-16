import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

SettingsBloc settingsBloc = SettingsBloc();

class SettingsBloc implements BlocBase {
  SettingsBloc() {
    _loadPrefs();
  }

  SharedPreferences _prefs;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    showBalance = _prefs.getBool('showBalance') ?? showBalance;
    isLightTheme = _prefs.getBool('isLightTheme') ?? isLightTheme;

    showSoundsExplanationDialog =
        _prefs.getBool('showSoundsExplanationDialog') ??
            showSoundsExplanationDialog;

    showCancelOrderDialog =
        _prefs.getBool('showCancelOrderDialog1') ?? showCancelOrderDialog;

    if (_prefs.getBool('showOrderDetailsByTap') == null) {
      _prefs.setBool('showOrderDetailsByTap', true);
    }

    enableTestCoins = _prefs.getBool('switch_test_coins') ?? enableTestCoins;
  }

  bool showBalance = true;
  bool isLightTheme = false;
  bool showSoundsExplanationDialog = true;
  bool showCancelOrderDialog = true;
  bool askCancelOrderAgain = true;
  bool enableTestCoins = false;

  final StreamController<bool> _showBalanceController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inShowBalance => _showBalanceController.sink;
  Stream<bool> get outShowBalance => _showBalanceController.stream;

  final StreamController<bool> _showSoundsDialogCtrl =
      StreamController<bool>.broadcast();
  Sink<bool> get _inShowSoundsDialog => _showSoundsDialogCtrl.sink;
  Stream<bool> get outShowSoundsDialog => _showSoundsDialogCtrl.stream;

  final StreamController<bool> _askCancelOrderAgainCtrl =
      StreamController<bool>.broadcast();
  Sink<bool> get _inAskCancelOrderAgain => _askCancelOrderAgainCtrl.sink;
  Stream<bool> get outAskCancelOrderAgain => _askCancelOrderAgainCtrl.stream;

  final StreamController<bool> _isLightThemeController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inLightTheme => _isLightThemeController.sink;
  Stream<bool> get outLightTheme => _isLightThemeController.stream;

  final StreamController<bool> _enableTestCoinsController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inEnableTestCoins => _enableTestCoinsController.sink;
  Stream<bool> get outEnableTestCoins => _enableTestCoinsController.stream;

  @override
  void dispose() {
    _showBalanceController?.close();
    _showSoundsDialogCtrl?.close();
    _inAskCancelOrderAgain?.close();
    _enableTestCoinsController?.close();
  }

  String getNameLanguage(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'en':
        return AppLocalizations.of(context).englishLanguage;
        break;
      case 'fr':
        return AppLocalizations.of(context).frenchLanguage;
        break;
      case 'de':
        return AppLocalizations.of(context).deutscheLanguage;
        break;
      case 'zh':
        return AppLocalizations.of(context).chineseLanguage;
        break;
      case 'ru':
        return AppLocalizations.of(context).russianLanguage;
        break;
      case 'ja':
        return AppLocalizations.of(context).japaneseLanguage;
        break;
      case 'tr':
        return AppLocalizations.of(context).turkishLanguage;
        break;
      case 'hu':
        return AppLocalizations.of(context).hungarianLanguage;
        break;
      case 'es':
        return AppLocalizations.of(context).spanishLanguage;
        break;
      default:
        return AppLocalizations.of(context).englishLanguage;
    }
  }

  void setShowBalance(bool val) {
    showBalance = val;
    _inShowBalance.add(val);
    _prefs.setBool('showBalance', val);
  }

  void setShowSoundsDialog(bool val) {
    showSoundsExplanationDialog = val;
    _inShowSoundsDialog.add(val);
    _prefs.setBool('showSoundsExplanationDialog', val);
  }

  void setShowCancelOrderDialog(bool val) {
    showCancelOrderDialog = val;
    _prefs.setBool('showCancelOrderDialog1', val);
  }

  void askAgainOnChanged(bool val) {
    askCancelOrderAgain = val;
    _inAskCancelOrderAgain.add(val);
  }

  void setLightTheme(bool val) {
    isLightTheme = val;
    _inLightTheme.add(val);
    _prefs.setBool('isLightTheme', val);
  }

  void setEnableTestCoins(bool val) {
    enableTestCoins = val;
    _inEnableTestCoins.add(val);
    _prefs.setBool('switch_test_coins', val);
  }
}
