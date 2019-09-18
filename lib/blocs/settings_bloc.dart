import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

SettingsBloc settingsBloc = SettingsBloc();

class SettingsBloc implements BlocBase{
  bool isDeleteLoading = true;

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

    String getNameLanguage(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'en':
        return AppLocalizations.of(context).englishLanguage;
        break;
      case 'fr':
        return AppLocalizations.of(context).frenchLanguage;
        break;
      case 'de':
        return AppLocalizations.of(context).deutscheLanguage;
        break;
      case 'zh':
        return AppLocalizations.of(context).chineseLanguage;
        break;
      default:
        return AppLocalizations.of(context).englishLanguage;
    }
  }
  
}