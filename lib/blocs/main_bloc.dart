import 'dart:async';
import 'dart:ui';

import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:komodo_dex/utils/log.dart';

MainBloc mainBloc = MainBloc();

class MainBloc implements BlocBase {
  int currentIndexTab = 0;

  final StreamController<int> _currentIndexTabController =
      StreamController<int>.broadcast();
  Sink<int> get _inCurrentIndex => _currentIndexTabController.sink;
  Stream<int> get outCurrentIndex => _currentIndexTabController.stream;

  bool isNetworkOffline = false;

  final StreamController<bool> _isNetworkOffline =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsNetworkOffline => _isNetworkOffline.sink;
  Stream<bool> get outIsNetworkOffline => _isNetworkOffline.stream;

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
    _isNetworkOffline.close();
    _currentLocaleController.close();
  }

  void setIsNetworkOffline(bool isNetworkAvailable) {
    isNetworkOffline = isNetworkAvailable;
    _inIsNetworkOffline.add(isNetworkOffline);
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
        Locale.fromSubtags(
            languageCode: 'zh',
            countryCode: 'TW'), // Taiwan simplified Chinese 'zh_TW'
        Locale('ru'),
        Locale('ja'),
        Locale('tr'),
        Locale('hu')
      ];

  bool get isInBackground => _isInBackground;
  set isInBackground(bool val) {
    if (val == _isInBackground) return;

    _isInBackground = val;
    _inIsInBackground.add(_isInBackground);
  }
}
