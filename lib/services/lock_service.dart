import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

LockService lockService = LockService();

/// Decides when (and how) to lock the screen.
class LockService {
  SharedPreferences _prefs;
  int _inFilePicker = 0;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// A user picking a file generally expects to return to the settings page and not to the lock screen.
  /// We suspend lock screen for a minute in order to maintain this UX expectation.
  int enteringFilePicker() {
    assert(!authBloc.isPinShow);
    final int now = DateTime.now().millisecondsSinceEpoch;
    _inFilePicker = now;
    Log.println('lock_service:24', 'enteringFilePicker');
    return now;
  }

  /// Must be called when the file picker `await` returns.
  void filePickerReturned(int lockCookie) {
    assert(lockCookie > 0);
    final int started = _inFilePicker;
    _inFilePicker = 0;
    Log.println('lock_service:33', 'filePickerReturned');

    if (started != lockCookie) {
      Log.println('lock_service:36', 'Warning, lockCookie mismatch!');
      _lock(null);
      return;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int delta = now - started;
    if (delta <= 333) {
      _lock(null);
      Log.println('lock_service:45', 'File picking was unrealistically fast.');
      return;
    }
    // We can't exempt file picker from lock screen forever,
    // for otherwise an attacker can later gain access by continuing an unfinished file picking activity.
    if (delta > 60 * 1000) {
      _lock(null);
      Log.println('lock_service:52', 'File picking took more than a minute.');
      return;
    }
  }

  /// File picker is a system activity that seizes the control from our app,
  /// triggering lifecycle events and invoking the LockService.
  /// We want to know whether we are still in the UI control path of that activity
  /// (suspended *behind it* or in the process of returning *from it*).
  /// If there is a tap before the file picker await returns
  /// then something is wrong and we should trigger the lock screen.
  void pointerEvent(BuildContext context) {
    Log.println('lock_service:64', 'pointerEvent');
    if (_inFilePicker != 0) {
      _inFilePicker = 0;
      _lock(context);
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
    Log.println('lock_service:84', 'lockSignal');
    if (_inFilePicker == 0) _lock(context);
  }

  void _lock(BuildContext context) {
    if (!authBloc.isPinShow) {
      Log.println('lock_service:90', 'locking...');
      if (context != null) dialogBloc.closeDialog(context);
      if (_prefs.getBool('switch_pin_log_out_on_exit')) authBloc.logout();
      if (!authBloc.isQrCodeActive) authBloc.showPin(true);
    }
  }
}
