import 'package:komodo_dex/packages/wallet_profiles/state/wallet_profiles_state.dart';

class WalletProfilesLoadInProgress extends WalletProfilesState {
  const WalletProfilesLoadInProgress();

  String get stateId => 'wallet_profiles_load_in_progress';

  @override
  List<Object> get props => [];

  static WalletProfilesLoadInProgress fromJson(Map<String, dynamic> json) =>
      WalletProfilesLoadInProgress();

  @override
  Map<String, dynamic> toJson() => {};
}
