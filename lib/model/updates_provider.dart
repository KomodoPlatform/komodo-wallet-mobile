import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/notif_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdatesProvider extends ChangeNotifier {
  UpdatesProvider() {
    _init();
  }

  final AppLocalizations _localizations = AppLocalizations();
  bool isFetching = false;
  UpdateStatus status;
  String currentVersion;
  String newVersion;
  String message;

  final String url = appConfig.updateCheckerEndpoint;

  Future<void> check() => _check();

  Future<void> _init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;

    if (appConfig.isUpdateCheckerEnabled) {
      jobService.install('checkUpdates', 300, (_) async {
        if (mainBloc.isInBackground) _check();
      });
    }

    notifyListeners();
  }

  Future<void> _check() async {
    isFetching = true;
    newVersion = null;
    status = null;
    message = null;
    notifyListeners();

    if (!appConfig.isUpdateCheckerEnabled) {
      status = UpdateStatus.upToDate;
      isFetching = false;
      notifyListeners();
      return;
    }

    http.Response response;
    Map<String, dynamic> json;

    try {
      response = await http
          .post(
        Uri.parse(url),
        body: jsonEncode({
          'currentVersion': currentVersion,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          Log('updates_provider:47', '_check] Timeout');

          isFetching = false;
          status = UpdateStatus.upToDate;
          notifyListeners();
          return;
        },
      );

      json = jsonDecode(response.body);
    } catch (e) {
      Log('updates_provider:47', '_check] $e');

      isFetching = false;
      status = UpdateStatus.upToDate;
      mainBloc.setNetworkStatus(NetworkStatus.Offline);
      notifyListeners();
      return;
    }

    message = json['message'];
    final String jsonVersion = json['newVersion'];
    if (jsonVersion != null && currentVersion != null) {
      if (jsonVersion.compareTo(currentVersion) > 0) {
        newVersion = jsonVersion;
      } else {
        isFetching = false;
        status = UpdateStatus.upToDate;
        notifyListeners();
        return;
      }
    }

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

    if (status != UpdateStatus.upToDate) {
      notifService.show(
        NotifObj(
          title: _localizations.updatesNotifTitle,
          text: newVersion == null
              ? _localizations.updatesNotifAvailable
              : _localizations.updatesNotifAvailableVersion(newVersion),
          uid: 'version_update',
        ),
      );
    }

    notifyListeners();
  }
}

enum UpdateStatus {
  upToDate,
  available,
  recommended,
  required,
}
