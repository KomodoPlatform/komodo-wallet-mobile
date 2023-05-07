// Export all states and models which are used in the state classes. This file
// acts as an 'index' for the state classes.

export 'wallets_initial.dart';
export 'wallets_load_failure.dart';
export 'wallets_load_success.dart';
export 'wallets_load_in_progress.dart';

import 'wallets_initial.dart';
import 'wallets_load_failure.dart';
import 'wallets_load_success.dart';
import 'wallets_load_in_progress.dart';

export 'package:komodo_dex/packages/accounts/models/account.dart';

abstract class WalletsState {
  const WalletsState();

  List<Object?> get props;

  Map<String, dynamic> toJson();

  // WalletProfilesState.fromJson(Map<String, dynamic> json);
}

extension WalletsStateIds on WalletsState {
  static const String _initial = 'wallets_initial';
  static const String _loadInProgress = 'wallets_load_in_progress';
  static const String _loadSuccess = 'wallets_load_success';
  static const String _loadFailure = 'wallets_load_failure';

  static const List<String> all = [
    _initial,
    _loadInProgress,
    _loadSuccess,
    _loadFailure,
  ];

  String get toStringStateId {
    switch (runtimeType) {
      case WalletsInitial:
        return _initial;
      case WalletsLoadInProgress:
        return _loadInProgress;
      case WalletsLoadSuccess:
        return _loadSuccess;
      case WalletsLoadFailure:
        return _loadFailure;
      default:
        throw Exception('Unknown state type: $runtimeType');
    }
  }

  static Type fromStringStateId(String stateId) {
    switch (stateId) {
      case _initial:
        return WalletsInitial;
      case _loadInProgress:
        return WalletsLoadInProgress;
      case _loadSuccess:
        return WalletsLoadSuccess;
      case _loadFailure:
        return WalletsLoadFailure;
      default:
        throw Exception('Unknown state type: $stateId');
    }
  }
}
