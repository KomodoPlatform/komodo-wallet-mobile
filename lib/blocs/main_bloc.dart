import 'dart:async';
import 'dart:ui';

import '../widgets/bloc_provider.dart';
import '../utils/log.dart';

MainBloc mainBloc = MainBloc();

class MainBloc implements BlocBase {
  int currentIndexTab = 0;
  int _tradeMode = 0; // 0: simple, 1: advanced, 2: multi

  final StreamController<int> _tradeModeController =
      StreamController<int>.broadcast();
  Sink<int> get _inTradeMode => _tradeModeController.sink;
  Stream<int> get outTradeMode => _tradeModeController.stream;

  final StreamController<int> _currentIndexTabController =
      StreamController<int>.broadcast();
  Sink<int> get _inCurrentIndex => _currentIndexTabController.sink;
  Stream<int> get outCurrentIndex => _currentIndexTabController.stream;

  NetworkStatus networkStatus = NetworkStatus.Online;

  final StreamController<NetworkStatus> _networkStatus =
      StreamController<NetworkStatus>.broadcast();
  Sink<NetworkStatus> get _inNetworkStatus => _networkStatus.sink;
  Stream<NetworkStatus> get outNetworkStatus => _networkStatus.stream;

  bool isUrlLaucherIsOpen = false;

  Locale currentLocale;

  final StreamController<Locale> _currentLocaleController =
      StreamController<Locale>.broadcast();
  Sink<Locale> get _inCurrentLocale => _currentLocaleController.sink;
  Stream<Locale> get outcurrentLocale => _currentLocaleController.stream;

  bool _isInBackground = false;
  final StreamController<bool> _isInBackgroundController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsInBackground => _isInBackgroundController.sink;
  Stream<bool> get outIsInBackground => _isInBackgroundController.stream;

  @override
  void dispose() {
    _currentIndexTabController.close();
    _networkStatus.close();
    _currentLocaleController.close();
  }

  void setNetworkStatus(NetworkStatus status) {
    networkStatus = status;
    _inNetworkStatus.add(status);
  }

  void setCurrentIndexTab(int index) {
    currentIndexTab = index;
    _inCurrentIndex.add(currentIndexTab);
  }

  void setNewLanguage(Locale locale) {
    Log.println('main_bloc:51', 'Set Language to: ' + locale.toString());
    currentLocale = locale;
    _inCurrentLocale.add(currentLocale);
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

  bool get isInBackground => _isInBackground;
  set isInBackground(bool val) {
    if (val == _isInBackground) return;

    _isInBackground = val;
    _inIsInBackground.add(_isInBackground);
  }

  int get tradeMode => _tradeMode;
  set tradeMode(int value) {
    _tradeMode = value;
    _inTradeMode.add(value);
  }
}

enum NetworkStatus { Offline, Checking, Restored, Online }
