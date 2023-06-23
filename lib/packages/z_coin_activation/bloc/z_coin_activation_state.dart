import 'package:flutter/foundation.dart';

enum ZCoinActivationProgressStep {
  StartingActivation,
  Activating,
}

enum ZCoinActivationFailureReason {
  FailedToActivateCoins,
  FailedToStartActivation,
  FailedToSetRequestedCoins,
  FailedToGetActivationStatus,
}

abstract class ZCoinActivationState {
  const ZCoinActivationState();

  ZCoinActivationInProgess asProgressOrNull() {
    if (this is ZCoinActivationInProgess) {
      return this as ZCoinActivationInProgess;
    }
    return null;
  }
}

class ZCoinActivationInitial extends ZCoinActivationState {}

class ZCoinActivationKnownState extends ZCoinActivationState {
  const ZCoinActivationKnownState(this.isActivated);

  final bool isActivated;
}

class ZCoinActivationInProgess extends ZCoinActivationState {
  const ZCoinActivationInProgess({
    @required this.progress,
    @required this.step,
    this.eta,
    this.startTime,
  });

  final double progress;
  final ZCoinActivationProgressStep step;
  final Duration eta; // nullable
  final DateTime startTime; // nullable
}

class ZCoinActivationSuccess extends ZCoinActivationState {}

class ZCoinActivationFailure extends ZCoinActivationState {
  const ZCoinActivationFailure(this.reason);

  final ZCoinActivationFailureReason reason;
}

class ZCoinActivationStatusLoading extends ZCoinActivationState {}

class ZCoinActivationStatusChecked extends ZCoinActivationState {
  const ZCoinActivationStatusChecked({@required this.isActivated});

  final bool isActivated;
}
