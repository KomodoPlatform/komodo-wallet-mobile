import 'package:equatable/equatable.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/packages/wallet_profiles/models/wallet_profile.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final WalletProfile? walletProfile;

  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.walletProfile,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(WalletProfile walletProfile)
      : this._(
          status: AuthenticationStatus.authenticated,
          walletProfile: walletProfile,
        );

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object?> get props => [status, walletProfile];
}
