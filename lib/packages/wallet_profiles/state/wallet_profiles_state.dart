// Export all states and models which are used in the state classes. This file
// acts as an 'index' for the state classes.

export 'wallet_profiles_initial.dart';
export 'wallet_profiles_load_failure.dart';
export 'wallet_profiles_load_in_progress.dart';
export 'wallet_profiles_load_success.dart';

import 'wallet_profiles_initial.dart';
import 'wallet_profiles_load_failure.dart';
import 'wallet_profiles_load_in_progress.dart';
import 'wallet_profiles_load_success.dart';

export 'package:komodo_dex/packages/wallet_profiles/models/wallet_profile.dart';

abstract class WalletProfilesState {
  const WalletProfilesState();

  List<Object?> get props;

  Map<String, dynamic> toJson();

  // WalletProfilesState.fromJson(Map<String, dynamic> json);
}

extension WalletProfilesStateIds on WalletProfilesState {
  static const String _initial = 'wallet_profiles_initial';
  static const String _loadInProgress = 'wallet_profiles_load_in_progress';
  static const String _loadSuccess = 'wallet_profiles_load_success';
  static const String _loadFailure = 'wallet_profiles_load_failure';

  static const List<String> all = [
    _initial,
    _loadInProgress,
    _loadSuccess,
    _loadFailure,
  ];

  String get toStringStateId {
    switch (runtimeType) {
      case WalletProfilesInitial:
        return _initial;
      case WalletProfilesLoadInProgress:
        return _loadInProgress;
      case WalletProfilesLoadSuccess:
        return _loadSuccess;
      case WalletProfilesLoadFailure:
        return _loadFailure;
      default:
        throw Exception('Unknown state type: $runtimeType');
    }
  }

  static Type fromStringStateId(String stateId) {
    switch (stateId) {
      case _initial:
        return WalletProfilesInitial;
      case _loadInProgress:
        return WalletProfilesLoadInProgress;
      case _loadSuccess:
        return WalletProfilesLoadSuccess;
      case _loadFailure:
        return WalletProfilesLoadFailure;
      default:
        throw Exception('Unknown state type: $stateId');
    }
  }
}
