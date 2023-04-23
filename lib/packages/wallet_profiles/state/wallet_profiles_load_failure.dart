import 'package:komodo_dex/packages/wallet_profiles/state/wallet_profiles_state.dart';

class WalletProfilesLoadFailure extends WalletProfilesState {
  const WalletProfilesLoadFailure({required this.errorMessage});

  String get stateId => 'wallet_profiles_load_failure';

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];

  static WalletProfilesLoadFailure fromJson(Map<String, dynamic> json) =>
      WalletProfilesLoadFailure(
        errorMessage: json['errorMessage'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'errorMessage': errorMessage,
      };
}
