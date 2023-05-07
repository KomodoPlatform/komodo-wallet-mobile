import 'package:komodo_dex/packages/wallets/models/wallet.dart';
import 'package:komodo_dex/packages/wallets/state/wallets_state.dart';

class WalletsLoadSuccess extends WalletsState {
  const WalletsLoadSuccess({required this.wallets});

  String get stateId => 'wallet_profiles_load_success';

  final List<Wallet> wallets;

  @override
  List<Object> get props => [wallets.map((e) => e.props).toList()];

  @override
  Map<String, dynamic> toJson() => {
        'wallets': wallets.map((e) => e.toJson()).toList(),
      };

  static WalletsLoadSuccess fromJson(Map<String, dynamic> json) =>
      WalletsLoadSuccess(
        wallets:
            (json['wallets'] as List).map((e) => Wallet.fromJson(e)).toList(),
      );
}
