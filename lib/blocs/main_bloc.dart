import 'dart:async';

import 'package:komodo_dex/main.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

final mainBloc = MainBloc();

class MainBloc implements BlocBase{

  int currentIndexTab = 0;
  
  StreamController<int> _currentIndexTabController =
      StreamController<int>.broadcast();
  Sink<int> get _inCurrentIndex => _currentIndexTabController.sink;
  Stream<int> get outCurrentIndex => _currentIndexTabController.stream;

  bool isNetworkOffline = false;
  
  StreamController<bool> _isNetworkOffline =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsNetworkOffline => _isNetworkOffline.sink;
  Stream<bool> get outIsNetworkOffline => _isNetworkOffline.stream;


  @override
  void dispose() {
    _currentIndexTabController.close();
    _isNetworkOffline.close();
  }

  void setIsNetworkOffline(bool isNetworkAvailable) {
    this.isNetworkOffline = isNetworkAvailable;
    _inIsNetworkOffline.add(this.isNetworkOffline);
  }
  
  void setCurrentIndexTab(int index) {
    this.currentIndexTab = index;
    _inCurrentIndex.add(this.currentIndexTab);
  }

}