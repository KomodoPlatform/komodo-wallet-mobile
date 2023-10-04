import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_api.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_eta_mixin.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_event.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_repository.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_state.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_notifications.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_activation_prefs.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_status.dart';

// TODO: Localize messages
class ZCoinActivationBloc
    extends Bloc<ZCoinActivationEvent, ZCoinActivationState>
    with ActivationEta {
  ZCoinActivationBloc() : super(ZCoinActivationInitial()) {
    on<ZCoinActivationRequested>(_handleActivationRequested);
    on<ZCoinActivationSetRequestedCoins>(_handleSetRequestedCoins);
    on<ZCoinActivationStatusRequested>(_handleActivationStatusRequested);
    on<ZCoinActivationCancelRequested>(_handleActivationCancelRequested);
  }

  final ZCoinActivationRepository _repository = ZCoinActivationRepository(
    ZCoinActivationApi(),
  );

  Future<void> _handleActivationRequested(
    ZCoinActivationRequested event,
    Emitter<ZCoinActivationState> emit,
  ) async {
    final toActivate = await _repository.outstandingZCoinActivations();
    final toActivateInitalCount = toActivate.length;

    try {
      final isAllCoinsEnabled = await _repository.isAllRequestedZCoinsEnabled();
      if (isAllCoinsEnabled) {
        add(ZCoinActivationStatusRequested());
        return;
      }

      final zhtlcActivationPrefs = await loadZhtlcActivationPrefs();
      SyncType zhtlcSyncType = zhtlcActivationPrefs['zhtlcSyncType'];

      emit(
        ZCoinActivationInProgess(
          progress: 0,
          message: 'Starting activation',
          eta: null,
          startTime: DateTime.now(),
        ),
      );
      await emit.forEach<ZCoinStatus>(
        _repository.activateRequestedZCoins(),
        onData: (coinStatus) {
          if (coinStatus.isFailed) {
            return ZCoinActivationFailure(
              'Failed to activate ZHTLC coins, please try again later',
            );
          }

          if (coinStatus.isActivated) {
            toActivate.remove(coinStatus.coin);
          }
          final coinsRemainingCount = toActivate.length;

          // Progress of the coin currently being activated
          final coinProgress = coinStatus.progress;

          final overallProgress = (1 -
                  (coinsRemainingCount / toActivateInitalCount) +
                  (coinProgress / toActivateInitalCount))
              .clamp(0.0, 1.0);

          final previousInProgressState = state is ZCoinActivationInProgess
              ? (state as ZCoinActivationInProgess)
              : null;

          final lastProgress = previousInProgressState?.progress ?? 0;

          final shouldShowNewProgress = overallProgress > lastProgress;

          final eta = calculateETA(overallProgress);

          if (zhtlcSyncType != SyncType.newTransactions) {
            _updateNotification(
              coinStatus,
              overallProgress: overallProgress,
              eta: eta,
            );
          }
          if (coinStatus.isActivated) {
            return ZCoinActivationSuccess('Completed ZHTLC activation');
          }
          return ZCoinActivationInProgess(
            progress: shouldShowNewProgress ? overallProgress : lastProgress,
            message: 'Activating ${coinStatus.coin}',
            eta: eta,
            startTime: previousInProgressState.startTime,
          );
        },
        onError: (e, s) {
          debugPrint('Failed to activate coins: $e');
          return ZCoinActivationFailure('Failed to activate coins');
        },
      );

      final isAllActivated = await _repository.isAllRequestedZCoinsEnabled();

      if (isAllActivated) {
        // This is not always success, it just means the list is empty
        // And this emit might remove another important notification
        // emit(ZCoinActivationSuccess('ZHTLC coins activation process ended'));
      } else {
        emit(ZCoinActivationFailure('Failed to activate coins'));
      }
    } catch (e) {
      debugPrint('Failed to start activation: $e');
      emit(
        ZCoinActivationFailure('Failed to start activation'),
      );
    } finally {
      await _clearNotification();
    }
  }

  Future<void> _handleSetRequestedCoins(
    ZCoinActivationSetRequestedCoins event,
    Emitter<ZCoinActivationState> emit,
  ) async {
    try {
      await _repository.setRequestedActivatedCoins(event.coins);
      emit(ZCoinActivationInitial());
    } catch (e) {
      debugPrint('Failed to set requested coins: $e');
      emit(
        ZCoinActivationFailure('Failed to set requested coins'),
      );
    }
  }

  Future<void> _handleActivationStatusRequested(
    ZCoinActivationStatusRequested event,
    Emitter<ZCoinActivationState> emit,
  ) async {
    try {
      final isAllCoinsEnabled = await _repository.isAllRequestedZCoinsEnabled();

      // TODO? Consider if better to base the "in progress" state on the
      // API task status instead of the existing bloc state.
      final isActivationInProgress = state is ZCoinActivationInProgess;

      if (!isActivationInProgress || isAllCoinsEnabled) {
        await _clearNotification();
      }

      ZCoinActivationState newState;
      if (isAllCoinsEnabled) {
        newState = isActivationInProgress
            ? ZCoinActivationSuccess('Activation in progress...')
            : ZCoinActivationKnownState(isAllCoinsEnabled);
      } else if (isActivationInProgress) {
        newState = state as ZCoinActivationInProgess;
      } else {
        newState = ZCoinActivationKnownState(isAllCoinsEnabled);
      }

      emit(newState);

      if (!isAllCoinsEnabled && !isActivationInProgress) {
        add(ZCoinActivationRequested());
      } else {
        _repository.willInitialize = false;
      }
    } catch (e) {
      debugPrint('Failed to get activation status: $e');
      emit(
        ZCoinActivationFailure('Failed to get activation status'),
      );
    }
  }

  Future<void> _handleActivationCancelRequested(
    ZCoinActivationCancelRequested event,
    Emitter<ZCoinActivationState> emit,
  ) async {
    try {
      await _repository.cancelAllZCoinActivations();
      emit(ZCoinActivationFailure('Cancelling ZHTLC activation...'));
    } catch (e) {
      debugPrint('Failed to cancel ZHTLC activation: $e');
      emit(
        ZCoinActivationFailure('Failed to cancel ZHTLC activation'),
      );
    }
  }

  Future<void> _updateNotification(
    ZCoinStatus currentCoinStatus, {
    @required double overallProgress,
    Duration eta = Duration.zero,
  }) async {
    return ZCoinProgressNotifications.showNotification(
      ticker: currentCoinStatus.coin,
      progress: overallProgress,
      eta: eta,
    );
  }

  Future<void> _clearNotification() async {
    return ZCoinProgressNotifications.clear();
  }
}
