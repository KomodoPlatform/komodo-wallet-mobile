import 'package:flutter/foundation.dart';

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
    @required this.message,
    this.eta,
    this.startTime,
  });

  final double progress;
  final String message;

  /// Nullable
  final Duration eta;

  /// Nullable
  final DateTime startTime;
}

class ZCoinActivationSuccess extends ZCoinActivationState {
  ZCoinActivationSuccess();
}

class ZCoinActivationFailure extends ZCoinActivationState {
  const ZCoinActivationFailure(this.reason);

  final ZCoinActivationFailureReason reason;
}

enum ZCoinActivationFailureReason {
  startFailed,
  cancelled,
  failedToCancel,
  failedAfterStart,
  failedOther,
}

class ZCoinActivationStatusLoading extends ZCoinActivationState {}

class ZCoinActivationStatusChecked extends ZCoinActivationState {
  const ZCoinActivationStatusChecked({@required this.isActivated});

  final bool isActivated;
}
