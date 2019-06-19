import 'dart:async';

import 'package:komodo_dex/widgets/bloc_provider.dart';

final settingsBloc = SettingsBloc();

class SettingsBloc implements BlocBase{
  bool isDeleteLoading;

  StreamController<bool> _isDeleteLoadingController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsDeleteLoading => _isDeleteLoadingController.sink;
  Stream<bool> get outIsDeleteLoading => _isDeleteLoadingController.stream;

  @override
  void dispose() {
    _isDeleteLoadingController.close();
  }

  void setDeleteLoading(bool isLoading) {
    this.isDeleteLoading = isLoading;
    _inIsDeleteLoading.add(this.isDeleteLoading);
  }
  
}