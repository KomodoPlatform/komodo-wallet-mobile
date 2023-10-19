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
import 'package:komodo_dex/utils/log.dart';

class ZCoinActivationBloc
    extends Bloc<ZCoinActivationEvent, ZCoinActivationState>
    with ActivationEta, ProgressCalculator {
  ZCoinActivationBloc() : super(ZCoinActivationInitial()) {
    on<ZCoinActivationRequested>(_handleActivationRequested);
    on<ZCoinActivationSetRequestedCoins>(_handleSetRequestedCoins);
    on<ZCoinActivationCancelRequested>(_handleActivationCancelRequested);
  }

  final ZCoinActivationRepository _repository = ZCoinActivationRepository(
    ZCoinActivationApi(),
  );

  Future<void> _handleActivationRequested(
    ZCoinActivationRequested event,
    Emitter<ZCoinActivationState> emit,
  ) async {
    final pendingCoinsToActivate = event.isResync
        ? await _repository.outstandingZCoinActivations()
        : await _repository.getRequestedActivatedCoins();

    final hasCoinsToActivate = pendingCoinsToActivate.isNotEmpty;

    if (!hasCoinsToActivate) {
      if (state is! ZCoinActivationInitial) emit(ZCoinActivationInitial());
      return;
    }

    final totalCoinsToActivateCount = pendingCoinsToActivate.length.toInt();

    try {
      final zhtlcActivationPrefs = await loadZhtlcActivationPrefs();
      SyncType zhtlcSyncType = zhtlcActivationPrefs['zhtlcSyncType'];

      emit(
        ZCoinActivationInProgess(
          progress: 0,
          message: 'Starting activation',
          isResync: event.isResync,
          eta: null,
          startTime: DateTime.now(),
        ),
      );

      final previouslyActivated =
          await _repository.zCoinsTickersWithPreviousActivation();

      await emit.forEach<ZCoinStatus>(
        event.isResync
            ? _repository.resyncZCoins()
            : _repository.activateRequestedZCoins(),
        onData: (coinStatus) {
          if (coinStatus.isFailed) {
            return ZCoinActivationFailure(
              ZCoinActivationFailureReason.failedAfterStart,
            );
          }

          final completedCoinsCount =
              totalCoinsToActivateCount - pendingCoinsToActivate.length;

          double overallProgress = calculateOverallProgress(
            completedCoinsCount,
            totalCoinsToActivateCount,
            coinStatus.progress,
          );

          if (coinStatus.isActivated) {
            pendingCoinsToActivate.remove(coinStatus.coin);
          }

          overallProgress = calculateSmoothProgress(overallProgress);

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
            ).ignore();
          }

          return ZCoinActivationInProgess(
            progress: shouldShowNewProgress ? overallProgress : lastProgress,
            message: 'Activating ${coinStatus.coin}',
            isResync: previouslyActivated.contains(coinStatus.coin),
            eta: eta,
            startTime: previousInProgressState?.startTime ?? DateTime.now(),
          );
        },
        onError: (e, s) {
          Log(
            'ZCoinActivationBloc:_handleActivationRequested',
            'Failed to activate coins: $e',
          );
          return ZCoinActivationFailure(
            ZCoinActivationFailureReason.failedAfterStart,
          );
        },
      );

      final isAllActivated = await _repository.isAllRequestedZCoinsEnabled();

      if (isAllActivated == true &&
          state.asProgressOrNull()?.isResync == false) {
        emit(ZCoinActivationSuccess());
      } else {
        emit(
          ZCoinActivationFailure(ZCoinActivationFailureReason.failedAfterStart),
        );
      }
    } catch (e) {
      debugPrint('Failed to start activation: $e');
      emit(
        ZCoinActivationFailure(ZCoinActivationFailureReason.startFailed),
      );
    } finally {
      if (state is ZCoinActivationInProgess) emit(ZCoinActivationInitial());

      await _clearNotification();

      resetEta();
      resetProgress();
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
        ZCoinActivationFailure(ZCoinActivationFailureReason.startFailed),
      );
    }
  }

  Future<void> _handleActivationCancelRequested(
    ZCoinActivationCancelRequested event,
    Emitter<ZCoinActivationState> emit,
  ) async {
    try {
      await _repository.cancelAllZCoinActivations();
      emit(ZCoinActivationFailure(ZCoinActivationFailureReason.cancelled));
    } catch (e) {
      debugPrint('Failed to cancel ZHTLC activation: $e');
      emit(
        ZCoinActivationFailure(ZCoinActivationFailureReason.failedToCancel),
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
