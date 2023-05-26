import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../widgets/bloc_provider.dart';
import '../utils/log.dart';

MainBloc mainBloc = MainBloc();

enum TradeMode { Simple, Advanced, Multi }

class MainBloc with ChangeNotifier implements GenericBlocBase {
  int _currentIndexTab = 0;
  int get currentIndexTab => _currentIndexTab;
  set currentIndexTab(int index) {
    _currentIndexTab = index;
    notifyListeners();
  }

  NetworkStatus _networkStatus = NetworkStatus.Online;
  NetworkStatus get networkStatus => _networkStatus;
  set networkStatus(NetworkStatus status) {
    _networkStatus = status;
    notifyListeners();
  }

  Locale? _currentLocale;
  Locale? get currentLocale => _currentLocale;
  set currentLocale(Locale? locale) {
    _currentLocale = locale;
    notifyListeners();
  }

  TradeMode _tradeMode = TradeMode.Simple;
  // Ideally the getter would be the same type as the field, but this is done
  // for backwards compatibility.
  int get tradeMode => _tradeMode.index;

  TradeMode get tradeModeEnum => _tradeMode;

  void setTradeMode(TradeMode value) {
    _tradeMode = value;
    notifyListeners();
  }

  bool _isUrlLaucherIsOpen = false;
  bool get isUrlLaucherIsOpen => _isUrlLaucherIsOpen;
  set isUrlLaucherIsOpen(bool value) {
    _isUrlLaucherIsOpen = value;
    notifyListeners();
  }

  bool _isInBackground = false;
  bool get isInBackground => _isInBackground;
  set isInBackground(bool value) {
    _isInBackground = value;
    notifyListeners();
  }

  @override
  void dispose() {
    // dispose of resources if necessary
  }

  void setNetworkStatus(NetworkStatus status) {
    networkStatus = status;
  }

  void setCurrentIndexTab(int index) {
    currentIndexTab = index;
  }

  void setNewLanguage(Locale locale) {
    Log('MainBloc.setNewLanguage','Set Language to: $locale');
    currentLocale = locale;
  }

  List<Locale> get supportedLocales => const <Locale>[
        Locale('en'),
        Locale('fr'),
        Locale('de'),
        Locale('zh'), // generic Chinese 'zh'
        Locale('ru'),
        Locale('ja'),
        Locale('tr'),
        Locale('hu'),
        Locale('es'),
        Locale('ko'),
        Locale('uk')
      ];
}

enum NetworkStatus { Offline, Checking, Restored, Online }
