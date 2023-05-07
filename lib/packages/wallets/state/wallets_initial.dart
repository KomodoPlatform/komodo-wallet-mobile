import 'package:komodo_dex/packages/wallets/state/wallets_state.dart';

class WalletsInitial extends WalletsState {
  const WalletsInitial();

  @override
  List<Object> get props => [];

  static WalletsInitial fromJson(Map<String, dynamic> json) => WalletsInitial();

  @override
  Map<String, dynamic> toJson() => {};
}
