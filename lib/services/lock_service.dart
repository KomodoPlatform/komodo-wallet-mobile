import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

LockService lockService = LockService();

/// Decides when (and how) to lock the screen.
class LockService {
  SharedPreferences _prefs;

  /// Fundamentally the app can be either visible or invisible (not on screen or hidden by something)
  /// and the lock screen is turned on whenever the app is invisible.
  ///
  /// As of Flutter 1.9 the livecycle states (inactive, paused, suspending) don't map reliably to visibility.
  /// That is, we don't really know when the app is visible and when it is invisible.
  /// For example, "inactive" is hit when the app is hidden by the iOS file picking dialogue
  /// and is hit again when the app is resumed,
  /// leaving us in the unknown on whether the app is still hidden or if it regained the screen.
  ///
  /// Hence we can't track the exact visibility through the lifecycle states,
  /// but we can treat them as a signal that the visibility was affected, triggering the lock screen.
  Future<void> lockSignal(BuildContext context) async {
    Log.println('lock_service:25', 'lockSignal');
    if (!authBloc.isPinShow) {
      Log.println('lock_service:27', 'locking...');
      dialogBloc.closeDialog(context);
      _prefs ??= await SharedPreferences.getInstance();
      if (_prefs.getBool('switch_pin_log_out_on_exit')) {
        authBloc.logout();
      }
      if (!authBloc.isQrCodeActive) {
        authBloc.showPin(true);
      }
    }
  }
}
