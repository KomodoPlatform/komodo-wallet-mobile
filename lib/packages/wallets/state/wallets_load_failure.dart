import 'package:komodo_dex/packages/wallets/state/wallets_state.dart';

class WalletsLoadFailure extends WalletsState {
  const WalletsLoadFailure({required this.errorMessage});

  String get stateId => 'wallet_profiles_load_failure';

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];

  static WalletsLoadFailure fromJson(Map<String, dynamic> json) =>
      WalletsLoadFailure(
        errorMessage: json['errorMessage'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'errorMessage': errorMessage,
      };
}
