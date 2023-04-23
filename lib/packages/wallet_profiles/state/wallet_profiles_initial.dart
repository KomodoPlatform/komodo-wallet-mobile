import 'package:komodo_dex/packages/wallet_profiles/state/wallet_profiles_state.dart';

class WalletProfilesInitial extends WalletProfilesState {
  const WalletProfilesInitial();

  @override
  List<Object> get props => [];

  static WalletProfilesInitial fromJson(Map<String, dynamic> json) =>
      WalletProfilesInitial();

  @override
  Map<String, dynamic> toJson() => {};
}
