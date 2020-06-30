import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/utils/log.dart';
import 'package:package_info/package_info.dart';

class UpdatesProvider extends ChangeNotifier {
  UpdatesProvider() {
    _init();
  }

  bool isFetching = false;
  UpdateStatus status;
  String currentVersion;
  String newVersion;
  String message;

  final String url = 'http://95.217.165.110/';

  Future<void> check() => _check();

  Future<void> _init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;

    notifyListeners();
  }

  Future<void> _check() async {
    isFetching = true;
    newVersion = null;
    status = null;
    message = null;
    notifyListeners();

    http.Response response;
    Map<String, dynamic> json;

    try {
      response = await http.post(
        url,
        body: jsonEncode({
          'currentVersion': currentVersion,
        }),
      );

      json = jsonDecode(response.body);
    } catch (e) {
      Log('updates_provider:47', '_check] $e');

      isFetching = false;
      status = UpdateStatus.upToDate;
      notifyListeners();
      return;
    }

    message = json['message'];
    final String jsonVersion = json['newVersion'];
    if (jsonVersion != null) {
      if (jsonVersion.compareTo(currentVersion) > 0) {
        newVersion = jsonVersion;
      } else {
        isFetching = false;
        status = UpdateStatus.upToDate;
        notifyListeners();
        return;
      }
    }

    print(newVersion);

    switch (json['status']) {
      case 'upToDate':
        {
          status = UpdateStatus.upToDate;
          break;
        }
      case 'available':
        {
          status = UpdateStatus.available;
          break;
        }
      case 'recommended':
        {
          status = UpdateStatus.recommended;
          break;
        }
      case 'required':
        {
          status = UpdateStatus.required;
          break;
        }
      default:
        status =
            newVersion == null ? UpdateStatus.upToDate : UpdateStatus.available;
    }

    isFetching = false;
    notifyListeners();
  }
}

enum UpdateStatus {
  upToDate,
  available,
  recommended,
  required,
}
