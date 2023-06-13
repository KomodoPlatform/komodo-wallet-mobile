import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_api.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_event.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_repository.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_state.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_status.dart';
import 'package:komodo_dex/services/db/database.dart';

// TODO: Localize messages
class ZCoinActivationBloc
    extends Bloc<ZCoinActivationEvent, ZCoinActivationState> {
  final ZCoinActivationRepository _repository = ZCoinActivationRepository(
    ZCoinActivationApi(),
  );

  ZCoinActivationBloc() : super(ZCoinActivationInitial()) {
    on<ZCoinActivationRequested>(_handleActivationRequested);
    on<ZCoinActivationStatusRequested>(_handleActivationStatusRequested);
  }

  Future<void> _handleActivationRequested(ZCoinActivationRequested event,
      Emitter<ZCoinActivationState> emit) async {
    final toActivate =
        (await _repository.getKnownZCoins()).map((e) => e.abbr).toList();
    final toActivateInitalCount = toActivate.length;

    try {
      final isAllCoinsEnabled = await _repository.isAllZCoinsEnabled();
      if (isAllCoinsEnabled) {
        emit(ZCoinActivationSuccess());
        return;
      }

      emit(ZCoinActivationInProgess(
        progress: 0,
        message: 'Starting activation',
      ));
      await emit.forEach<ZCoinStatus>(_repository.activateAllZCoins(),
          onData: (coinStatus) {
        if (coinStatus.isFailed) {
          return state;
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

        final previousStateProgress = state is ZCoinActivationInProgess
            ? (state as ZCoinActivationInProgess).progress
            : null;

        final shouldShowNewProgress = previousStateProgress == null ||
            overallProgress > previousStateProgress;

        return ZCoinActivationInProgess(
          progress:
              shouldShowNewProgress ? overallProgress : previousStateProgress,
          message: 'Activating ${coinStatus.coin}',
        );
      }, onError: (e, s) {
        debugPrint('Failed to activate coins: $e');
        return ZCoinActivationFailure('Failed to activate coins');
      });

      emit(ZCoinActivationSuccess());
    } catch (e) {
      debugPrint('Failed to start activation: $e');
      emit(
        ZCoinActivationFailure('Failed to start activation'),
      );
    }
  }

  Future<void> _handleActivationStatusRequested(
      ZCoinActivationStatusRequested event,
      Emitter<ZCoinActivationState> emit) async {
    try {
      final isEnabled = await _repository.isAllZCoinsEnabled();
      final requestedCoins = await _repository.requestedActivatedCoins();

      final hasOutStaningActivationTasks =
          await _repository.hasOutstandingActivationRequest();

      if (state is ZCoinActivationInProgess) {
        return;
      }

      if (hasOutStaningActivationTasks) {
        add(ZCoinActivationRequested());
      }
    } catch (e) {
      debugPrint('Failed to check activation status: $e');
    }
  }
}
