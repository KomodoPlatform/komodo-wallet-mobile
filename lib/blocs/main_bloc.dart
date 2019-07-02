import 'dart:async';

import 'package:komodo_dex/widgets/bloc_provider.dart';

final mainBloc = MainBloc();

class MainBloc implements BlocBase{

  int currentIndexTab = 0;
  
  StreamController<int> _currentIndexTabController =
      StreamController<int>.broadcast();
  Sink<int> get _inCurrentIndex => _currentIndexTabController.sink;
  Stream<int> get outCurrentIndex => _currentIndexTabController.stream;

  bool isNetworkAvailable = false;
  
  StreamController<bool> _isNetworkAvailableController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsNetworkAvailable => _isNetworkAvailableController.sink;
  Stream<bool> get outIsNetworkAvailable => _isNetworkAvailableController.stream;


  @override
  void dispose() {
    _currentIndexTabController.close();
    _isNetworkAvailableController.close();
  }

  void setIsNetworkAvailable(bool isNetworkAvailable) {
    this.isNetworkAvailable = isNetworkAvailable;
    _inIsNetworkAvailable.add(this.isNetworkAvailable);
  }
  
  void setCurrentIndexTab(int index) {
    this.currentIndexTab = index;
    _inCurrentIndex.add(this.currentIndexTab);
  }

}