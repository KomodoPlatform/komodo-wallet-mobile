import 'dart:async';

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

  @override
  void dispose() {
    _currentIndexTabController.close();
    _isNetworkOffline.close();
  }

  void setIsNetworkOffline(bool isNetworkAvailable) {
    isNetworkOffline = isNetworkAvailable;
    _inIsNetworkOffline.add(isNetworkOffline);
  }

  void setCurrentIndexTab(int index) {
    currentIndexTab = index;
    _inCurrentIndex.add(currentIndexTab);
  }

}
