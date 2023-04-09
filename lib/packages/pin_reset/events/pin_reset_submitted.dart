import 'package:komodo_dex/packages/pin_reset/events/index.dart';

/// Event triggered when the pin reset form is submitted.
///
/// This event should initiate the validation and submission process for the pin reset.
class PinResetSubmitted extends PinResetEvent {
  const PinResetSubmitted();
}
