import 'package:flutter/foundation.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generic_blocs/authenticate_bloc.dart';
import '../generic_blocs/camo_bloc.dart';
import '../model/wallet_security_settings_provider.dart';
import '../services/mm_service.dart';
import '../utils/encryption_tool.dart';
import '../utils/log.dart';
import '../utils/utils.dart';

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

/// Manage startup sequence
class Startup {
  bool _started = false;
  bool _live = false;
  final String _log = '';
  int _startingMM = 0;

  bool get live => _live;
  String get log => _log;

  /// Initiate the startup sequence
  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _start();
  }

  Future<void> _start() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    await Db.init();

    // delete old logs
    await Log.maintain();

    await walletSecuritySettingsProvider.migrateSecuritySettings();

    _live = true;
    _notifyListeners();

    Log('startup', 'Startup sequence completed in ${stopwatch.elapsed}');

    stopwatch
      ..stop()
      ..reset();
  }

  /// Start MM but only if the passphrase is currently unlocked.
  /// Note that MM is usually started elsewhere (cf. _PinPageState._onCodeSuccess),
  /// though maybe we'll rectify this and unify MM startup code yet.
  Future<void> startMmIfUnlocked() async {
    // The method is public and we should defend from it being invoked in parallel
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - _startingMM).abs() < 3141) return;
    _startingMM = now;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isPassphraseIsSaved') != null &&
        prefs.getBool('isPassphraseIsSaved') == true) {
      // If the screen is currently unlocked then proceed with MM initialization
      await pauseUntil(() => walletSecuritySettingsProvider.isInitialized);
      if (!(authBloc.showLock &&
          walletSecuritySettingsProvider.activatePinProtection)) {
        await authBloc.login(await EncryptionTool().read('passphrase'), null);
      }
    }

    const screenshot = bool.fromEnvironment('screenshot', defaultValue: false);
    if (screenshot) {
      prefs.setBool('disallowScreenshot', false);
      MMService.nativeC.invokeMethod('is_screenshot');
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
