import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shares the progress on startup tasks with the UI
class StartupProvider extends ChangeNotifier {
  StartupProvider() {
    startup.linkProvider(this);
  }

  @override
  void dispose() {
    startup.unlinkProvider(this);
    super.dispose();
  }

  void notify() => notifyListeners();

  /// `true` if the application is ready to be used,
  /// `false` if we are in a startup sequence
  bool get live => startup.live;
  String get log => startup.log;
}

Startup startup = Startup();

class Startup {
  bool _started = false;
  bool _live = false;
  String _log = '';
  int _startingMM = 0;

  bool get live => _live;
  String get log => _log;

  /// Initiate the startup sequence
  void start() {
    if (_started) return;
    _started = true;
    _start(); // Will run in background
  }

  Future<void> _start() async {
    if (Platform.isAndroid)
      await mmSe.updateMmBinary((String line) {
        _log += '\n$line';
        _notifyListeners();
      });

    _log += '\nStarting MM…';
    await startMM();

    _live = true;
    _notifyListeners();
  }

  Future<void> startMM() async {
    // The method is public and we should defend from it being invoked in parallel
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - _startingMM).abs() < 3141) return;
    _startingMM = now;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isPassphraseIsSaved') != null &&
        prefs.getBool('isPassphraseIsSaved') == true) {
      await authBloc.initSwitchPref();

      if (!(authBloc.showLock && prefs.getBool('switch_pin'))) {
        await authBloc.login(await EncryptionTool().read('passphrase'), null);
      }
    }
  }

  // --- link to StartupProvider ---

  /// [ChangeNotifier] proxies linked to this singleton.
  final Set<StartupProvider> _providers = {};

  /// Link a [ChangeNotifier] proxy to this singleton.
  void linkProvider(StartupProvider provider) {
    _providers.add(provider);
  }

  /// Unlink a [ChangeNotifier] proxy from this singleton.
  void unlinkProvider(StartupProvider provider) {
    _providers.remove(provider);
  }

  void _notifyListeners() {
    for (StartupProvider provider in _providers) provider.notify();
  }
}
