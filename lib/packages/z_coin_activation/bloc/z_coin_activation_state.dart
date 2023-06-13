import 'package:flutter/foundation.dart';

abstract class ZCoinActivationState {
  const ZCoinActivationState();
}

class ZCoinActivationInitial extends ZCoinActivationState {}

class ZCoinActivationInProgess extends ZCoinActivationState {
  const ZCoinActivationInProgess({
    @required this.progress,
    @required this.message,
  });

  final double progress;
  final String message;
}

class ZCoinActivationSuccess extends ZCoinActivationState {}

class ZCoinActivationFailure extends ZCoinActivationState {
  const ZCoinActivationFailure(this.message);

  final String message;
}

class ZCoinActivationStatusLoading extends ZCoinActivationState {}

class ZCoinActivationStatusChecked extends ZCoinActivationState {
  const ZCoinActivationStatusChecked({@required this.isActivated});

  final bool isActivated;
}
