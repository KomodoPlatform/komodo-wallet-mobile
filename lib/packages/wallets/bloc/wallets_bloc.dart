import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/packages/wallets/events/wallets_event.dart';
import 'package:komodo_dex/packages/wallets/events/wallets_load_requested.dart';
import 'package:komodo_dex/packages/wallets/models/wallet.dart';
import 'package:komodo_dex/packages/wallets/repository/wallets_repository.dart';
import 'package:komodo_dex/packages/wallets/state/wallets_state.dart';
import 'package:bip39/bip39.dart' as bip39;

// TODO: Listen to realtime changes from the repository.
class WalletsBloc extends HydratedBloc<WalletsEvent, WalletsState> {
  final WalletsRepository _walletRepository;

  WalletsBloc({required WalletsRepository walletRepository})
      : _walletRepository = walletRepository,
        super(WalletsInitial()) {
    on<WalletsLoadRequested>(_onWalletsLoadRequested);
  }

  Future<void> testingAddWallet(Wallet wallet) async {
    if (!kDebugMode) {
      throw Exception(
          'This method is only available in debug mode for testing.');
    }

    final testPassphrase = bip39.generateMnemonic();
    debugPrint('Test passphrase generated: $testPassphrase');
    await _walletRepository.createWallet(
      wallet: wallet,
      passphrase: testPassphrase,
    );
    add(WalletsLoadRequested());
  }

  Future<void> testingRemoveAllWallets() async {
    if (!kDebugMode) {
      throw Exception('This method is only available in debug mode.');
    }
    final futures = <Future>[];
    final wallets = await _walletRepository.listWallets();
    for (final wallet in wallets) {
      futures.add(_walletRepository.removeWallet(wallet.walletId));
    }
    await Future.wait(futures);
    add(WalletsLoadRequested());
  }

  Future<void> _onWalletsLoadRequested(
      WalletsLoadRequested event, Emitter<WalletsState> emit) async {
    // We are only emitting the loading state if the current state does not
    // already have a list of wallets. This is done for UX purposes so that
    // the loading happens "automagically".
    // In some cases, you may want to explicitly inform the user that the list
    // of wallets is being refreshed.

    final hasWallets = state is WalletsLoadSuccess &&
        (state as WalletsLoadSuccess).wallets.isNotEmpty;

    if (!hasWallets) {
      emit(WalletsLoadInProgress());
    }

    try {
      final wallets = await _walletRepository.listWallets();

      emit(WalletsLoadSuccess(wallets: wallets));
    } catch (e) {
      emit(WalletsLoadFailure(errorMessage: e.toString()));
    }
  }

  @override
  WalletsState? fromJson(Map<String, dynamic> json) {
    final stateId = json['stateId'] as String?;

    if (stateId == null) {
      return null;
    }

    final type = WalletsStateIds.fromStringStateId(stateId);

    final data = json['data'] as Map<String, dynamic>;

    switch (type) {
      case WalletsInitial:
        return WalletsInitial.fromJson(data);
      case WalletsLoadInProgress:
        return WalletsLoadInProgress.fromJson(data);
      case WalletsLoadFailure:
        return WalletsLoadFailure.fromJson(data);
      case WalletsLoadSuccess:
        return WalletsLoadSuccess.fromJson(data);
      default:
        throw Exception('Unknown state type: $type');
    }
  }

  @override
  Map<String, dynamic>? toJson(WalletsState state) {
    return {
      'stateId': state.toStringStateId,
      'data': state.toJson(),
    };
  }
}
