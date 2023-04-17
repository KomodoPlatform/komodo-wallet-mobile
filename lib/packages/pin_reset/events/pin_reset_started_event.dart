import 'package:komodo_dex/login/models/pin_type.dart';
import 'package:komodo_dex/packages/pin_reset/events/index.dart';

class PinResetStarted extends PinResetEvent {
  const PinResetStarted(this.pinType);

  final PinTypeName pinType;

  @override
  List<Object?> get props => [pinType];
}
