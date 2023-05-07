import 'package:equatable/equatable.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/wallets/models/wallet.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final Wallet? wallet;

  bool get isAuthenticated => status == AuthenticationStatus.authenticated;

  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.wallet,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(Wallet wallet)
      : this._(
          status: AuthenticationStatus.authenticated,
          wallet: wallet,
        );

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  Map<String, dynamic> toJson() => {
        'status': status.toString(),
        'wallet': wallet?.toJson(),
      };

  static AuthenticationState fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String;
    final wallet = json['wallet'] as Map<String, dynamic>?;
    return AuthenticationState._(
      status: AuthenticationStatus.values.firstWhere(
        (e) => e.toString() == status,
      ),
      wallet: wallet != null ? Wallet.fromJson(wallet) : null,
    );
  }

  @override
  List<Object?> get props => [status, wallet];
}
