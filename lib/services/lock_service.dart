import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

LockService lockService = LockService();

/// Decides when (and how) to lock the screen.
class LockService {
  SharedPreferences _prefs;
  int _inFilePicker = 0;
  int _inQrScanner = 0;
  int _inBiometrics = 0;

  /// Time when we have last returned from an external dialogue (such as file picker or QR scan)
  /// withing the acceptable security constraints.
  /// Used to ignore the lock signals which are coming *in parallel* with the return.
  int _lastReturn = 0;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// A user picking a file generally expects to return to the settings page and not to the lock screen.
  /// We suspend lock screen for a minute in order to maintain this UX expectation.
  int enteringFilePicker() {
    assert(!authBloc.showLock);
    final int now = DateTime.now().millisecondsSinceEpoch;
    _inFilePicker = now;
    Log.println('lock_service:32', 'enteringFilePicker');
    return now;
  }

  int enteringQrScanner() {
    Log.println('lock_service:37', 'enteringQrScanner');
    return _inQrScanner = DateTime.now().millisecondsSinceEpoch;
  }

  int enteringBiometrics() {
    Log.println('lock_service:42', 'enteringBiometrics');
    return _inBiometrics = DateTime.now().millisecondsSinceEpoch;
  }

  /// Whether the user has left the app by activating the system file picker dialogue.
  bool get inFilePicker => _inFilePicker > 0;

  /// Whether the user has left the app by activating the system QR scanner dialogue.
  bool get inQrScanner => _inQrScanner > 0;

  /// Whether the user has left the app by activating the system biometrics dialogue.
  bool get inBiometrics => _inBiometrics > 0;

  /// Must be called when the file picker `await` returns.
  void filePickerReturned(int lockCookie) {
    assert(lockCookie > 0);
    final int started = _inFilePicker;
    _inFilePicker = 0;
    Log.println('lock_service:60', 'filePickerReturned');

    if (started != lockCookie) {
      Log.println('lock_service:63', 'Warning, lockCookie mismatch!');
      _lock(null);
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int delta = now - started;
    if (delta <= 333) {
      _lock(null);
      Log.println('lock_service:72', 'File picking was unrealistically fast.');
      return;
    }
    // We can't exempt file picker from lock screen forever,
    // for otherwise an attacker can later gain access by continuing an unfinished file picking activity.
    if (delta > 60 * 1000) {
      _lock(null);
      Log.println('lock_service:79', 'File picking took more than a minute.');
      return;
    }

    _lastReturn = now;
  }

  void qrScannerReturned(int lockCookie) {
    Log.println('lock_service:87', 'qrScannerReturned');
    assert(lockCookie > 0);
    final int started = _inQrScanner;
    _inQrScanner = 0;
    if (started != lockCookie) {
      Log.println('lock_service:92', 'Warning, lockCookie mismatch!');
      _lock(null);
      return;
    }

    // We can't exempt the QR scanner from locking the screen forever,
    // for otherwise an attacker can later gain access by continuing an unfinished QR activity.
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int delta = now - started;
    if (delta > 5 * 60 * 1000) {
      _lock(null);
      Log.println('lock_service:103', 'QR took more than five minutes.');
      return;
    }

    _lastReturn = now;
  }

  void biometricsReturned(int lockCookie) {
    Log.println('lock_service:111', 'biometricsReturned');
    _inBiometrics = 0;
    _lastReturn = DateTime.now().millisecondsSinceEpoch;
  }

  /// File picker is a system activity that seizes the control from our app,
  /// triggering lifecycle events and invoking the LockService.
  /// We want to know whether we are still in the UI control path of that activity
  /// (suspended *behind it* or in the process of returning *from it*).
  /// If there is a tap before the file picker `await` returns
  /// then something is wrong and we should trigger the lock screen.
  void pointerEvent(BuildContext context) {
    //Log.println('lock_service:123', 'pointerEvent');
    if (_inFilePicker != 0) {
      _inFilePicker = 0;
      _lock(context);
    }

    // If there is a tap then we have returned from the QR.
    _inQrScanner = 0;

    if (_inBiometrics != 0) {
      // If there is a tap then we're not in biometrics anymore.
      _inBiometrics = 0;
      _lastReturn = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Fundamentally the app can be either visible or invisible (not on screen or hidden by something)
  /// and the lock screen is turned on whenever the app is invisible.
  ///
  /// As of Flutter 1.9 the livecycle states (inactive, paused, suspending) don't map reliably to visibility.
  /// That is, we don't really know when the app is visible and when it is invisible.
  /// For example, "inactive" is hit when the app is hidden by the iOS file picking dialogue
  /// and is hit again when the app is resumed,
  /// leaving us in the unknown on whether the app is still hidden or if it regained the screen.
  /// (cf. https://github.com/flutter/flutter/issues/4553#issuecomment-445308514)
  ///
  /// Hence we can't track the exact visibility through the lifecycle states,
  /// but we can treat them as a signal that the visibility was affected, triggering the lock screen.
  void lockSignal(BuildContext context) {
    Log.println('lock_service:152', 'lockSignal');
    if (_inFilePicker == 0) _lock(context);
  }

  void _lock(BuildContext context) {
    if (authBloc.showLock) return; // Already showing the lock.
    if (inQrScanner) return; // Don't lock while we're scanning QR.
    if (_prefs.getBool('switch_pin') == false) return; // PIN turned off

    // Lock signals are coming *concurrently and in parallel* with the returns
    // and might arrive both before and *after* them.
    // That is, if `_lastReturn` is recent then we are most likely *still returning*.
    // NB: Deltas like 949ms are a norm when returning from biometrics in a flutter debug, under simulator,
    // probably because it also triggers a number of other resource-intensitive things.
    final int lrDelta = DateTime.now().millisecondsSinceEpoch - _lastReturn;
    Log.println('lock_service:166', '_lastReturn delta: $lrDelta');
    if (isInDebugMode) {
      // Delays tend to be higher in the debug mode,
      // cf. https://github.com/ca333/komodoDEX/issues/672#issuecomment-586757030
      if (lrDelta < 2222) return;
    } else {
      if (lrDelta < 999) return;
    }

    // #496: When a text fields is hidden in a focused state and then later shows up again,
    // it might stuck in some intermediate state, preventing the long press menus, such as "PASTE",
    // from appearing. Unfocusing before hiding such fields workarounds the issue.
    Log.println('lock_service:178', 'Unfocus and lock..');
    FocusScope.of(context).requestFocus(FocusNode());

    if (_prefs.getBool('switch_pin_log_out_on_exit')) authBloc.logout();
    authBloc.showLock = true;
  }
}
