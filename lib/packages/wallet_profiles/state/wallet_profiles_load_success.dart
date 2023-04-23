import 'package:komodo_dex/packages/wallet_profiles/state/wallet_profiles_state.dart';

class WalletProfilesLoadSuccess extends WalletProfilesState {
  const WalletProfilesLoadSuccess({required this.wallets});

  String get stateId => 'wallet_profiles_load_success';

  final List<WalletProfile> wallets;

  @override
  List<Object> get props => [wallets.map((e) => e.props).toList()];

  @override
  Map<String, dynamic> toJson() => {
        'wallets': wallets.map((e) => e.toJson()).toList(),
      };

  static WalletProfilesLoadSuccess fromJson(Map<String, dynamic> json) =>
      WalletProfilesLoadSuccess(
        wallets: (json['wallets'] as List)
            .map((e) => WalletProfile.fromJson(e))
            .toList(),
      );
}
