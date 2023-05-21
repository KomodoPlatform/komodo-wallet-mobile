import 'package:komodo_dex/packages/wallets/events/wallets_event.dart';

class WalletsQuickCreateSubmitted extends WalletsEvent {
  final String name;
  final String description;

  const WalletsQuickCreateSubmitted({
    required this.name,
    required this.description,
  });

  @override
  List<Object> get props => [name, description];
}
