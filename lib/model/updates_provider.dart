import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';

class UpdatesProvider extends ChangeNotifier {
  UpdatesProvider() {
    _init();
  }

  bool isFetching = false;
  UpdateStatus status;
  String currentVersion;
  String newVersion;

  Future<void> check() => _check();

  Future<void> _init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;

    notifyListeners();
  }

  Future<void> _check() async {
    isFetching = true;
    notifyListeners();

    await Future<dynamic>.delayed(const Duration(seconds: 3));

    status = UpdateStatus.updateRecommended;
    newVersion = '0.2.17';

    isFetching = false;
    notifyListeners();
  }
}

enum UpdateStatus {
  upToDate,
  newVersionAvailable,
  updateRecommended,
  updateRequired,
}
