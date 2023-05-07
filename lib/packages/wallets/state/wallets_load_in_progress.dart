import 'package:komodo_dex/packages/wallets/state/wallets_state.dart';

class WalletsLoadInProgress extends WalletsState {
  const WalletsLoadInProgress();

  String get stateId => 'wallets_load_in_progress';

  @override
  List<Object> get props => [];

  static WalletsLoadInProgress fromJson(Map<String, dynamic> json) =>
      WalletsLoadInProgress();

  @override
  Map<String, dynamic> toJson() => {};
}
