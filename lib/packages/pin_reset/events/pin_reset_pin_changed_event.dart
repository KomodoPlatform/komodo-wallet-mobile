import 'package:komodo_dex/packages/pin_reset/events/index.dart';

/// Event dispatched when the pin input is updated by the user. NB: This is not
/// the same as the pin being submitted or when the pin. "Changed" refers
/// to the input value changing, not the saved pin.
class PinResetPinChanged extends PinResetEvent {
  const PinResetPinChanged(this.pin);

  final String pin;

  @override
  List<Object?> get props => [pin];
}
