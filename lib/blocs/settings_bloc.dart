import 'dart:async';

import 'package:komodo_dex/widgets/bloc_provider.dart';

SettingsBloc settingsBloc = SettingsBloc();

class SettingsBloc implements BlocBase{
  bool isDeleteLoading;

  final StreamController<bool> _isDeleteLoadingController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsDeleteLoading => _isDeleteLoadingController.sink;
  Stream<bool> get outIsDeleteLoading => _isDeleteLoadingController.stream;

  @override
  void dispose() {
    _isDeleteLoadingController.close();
  }

  void setDeleteLoading(bool isLoading) {
    isDeleteLoading = isLoading;
    _inIsDeleteLoading.add(isDeleteLoading);
  }
  
}