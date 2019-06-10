import 'dart:async';

import 'package:komodo_dex/widgets/bloc_provider.dart';

final mainBloc = MainBloc();

class MainBloc implements BlocBase{

  int currentIndexTab = 0;
  
  StreamController<int> _currentIndexTabController =
      StreamController<int>.broadcast();
  Sink<int> get _inCurrentIndex => _currentIndexTabController.sink;
  Stream<int> get outCurrentIndex => _currentIndexTabController.stream;



  @override
  void dispose() {
    _currentIndexTabController.close();
  }
  
  void setCurrentIndexTab(int index) {
    this.currentIndexTab = index;
    _inCurrentIndex.add(this.currentIndexTab);
  }

}