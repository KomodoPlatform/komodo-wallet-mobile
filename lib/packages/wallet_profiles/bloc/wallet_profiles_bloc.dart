import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/packages/wallet_profiles/events/wallet_profiles_event.dart';
import 'package:komodo_dex/packages/wallet_profiles/events/wallet_profiles_load_requested.dart';
import 'package:komodo_dex/packages/wallet_profiles/repository/wallet_repository.dart';
import 'package:komodo_dex/packages/wallet_profiles/state/wallet_profiles_state.dart';

// TODO: Listen to realtime changes from the repository.
class WalletProfilesBloc
    extends HydratedBloc<WalletProfilesEvent, WalletProfilesState> {
  final WalletRepository _walletRepository;

  WalletProfilesBloc({required WalletRepository walletRepository})
      : _walletRepository = walletRepository,
        super(WalletProfilesInitial()) {
    on<WalletProfilesLoadRequested>(_onWalletProfilesLoadRequested);
  }

  Future<void> testingAddWallet(WalletProfile profile) async {
    if (!kDebugMode) {
      throw Exception('This method is only available in debug mode.');
    }
    await _walletRepository.storeWalletProfile(profile);
    add(WalletProfilesLoadRequested());
  }

  Future<void> testingRemoveAllWallets() async {
    if (!kDebugMode) {
      throw Exception('This method is only available in debug mode.');
    }
    final futures = <Future>[];
    final wallets = await _walletRepository.listWalletProfiles();
    for (final wallet in wallets) {
      futures.add(_walletRepository.removeWalletProfile(wallet.id));
    }
    await Future.wait(futures);
    add(WalletProfilesLoadRequested());
  }

  Future<void> _onWalletProfilesLoadRequested(WalletProfilesLoadRequested event,
      Emitter<WalletProfilesState> emit) async {
    // We are only emitting the loading state if the current state does not
    // already have a list of wallets. This is done for UX purposes so that
    // the loading happens "automagically".
    // In some cases, you may want to explicitly inform the user that the list
    // of wallets is being refreshed.

    final hasWallets = state is WalletProfilesLoadSuccess &&
        (state as WalletProfilesLoadSuccess).wallets.isNotEmpty;

    if (!hasWallets) {
      emit(WalletProfilesLoadInProgress());
    }

    try {
      final wallets = await _walletRepository.listWalletProfiles();

      emit(WalletProfilesLoadSuccess(wallets: wallets));
    } catch (e) {
      emit(WalletProfilesLoadFailure(errorMessage: e.toString()));
    }
  }

  @override
  WalletProfilesState? fromJson(Map<String, dynamic> json) {
    final stateId = json['stateId'] as String?;

    if (stateId == null) {
      return null;
    }

    final type = WalletProfilesStateIds.fromStringStateId(stateId);

    final data = json['data'] as Map<String, dynamic>;

    switch (type) {
      case WalletProfilesInitial:
        return WalletProfilesInitial.fromJson(data);
      case WalletProfilesLoadInProgress:
        return WalletProfilesLoadInProgress.fromJson(data);
      case WalletProfilesLoadFailure:
        return WalletProfilesLoadFailure.fromJson(data);
      case WalletProfilesLoadSuccess:
        return WalletProfilesLoadSuccess.fromJson(data);
      default:
        throw Exception('Unknown state type: $type');
    }
  }

  @override
  Map<String, dynamic>? toJson(WalletProfilesState state) {
    return {
      'stateId': state.toStringStateId,
      'data': state.toJson(),
    };
  }
}
