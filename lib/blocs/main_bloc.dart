import 'dart:async';
import 'dart:ui';

import 'package:komodo_dex/widgets/bloc_provider.dart';

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
            scriptCode: 'Hans'), // generic simplified Chinese 'zh_Hans'
        Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant'), // generic traditional Chinese 'zh_Hant'
      ];
}
