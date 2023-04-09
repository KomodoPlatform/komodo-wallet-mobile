import 'package:flutter/foundation.dart';
import 'package:komodo_dex/login/models/pin_type.dart';
import 'package:komodo_dex/packages/pin_reset/events/index.dart';

/// Event to start the process of setting up a new PIN, Can also be used to
/// reset an existing PIN if the current PIN is unknown but the user knows the
/// password.
///
/// See notes in [AuthenticationRepository] for more info on future plans for
/// implementing a more secure authentication flow for setting/resetting pins
/// so that the password does not need to be kept in memory.
@immutable
class PinSetupStarted extends PinResetEvent {
  const PinSetupStarted({
    required this.pinType,
    required this.password,
  });

  final PinTypeName pinType;

  final String password;

  @override
  List<Object?> get props => [pinType, password];
}
