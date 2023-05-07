// TODO: Refactor into smaller classes following this project's architecture.
// This code is originally from a different project.

part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationStatusChanged extends AuthenticationEvent {
  final AuthenticationStatus status;

  const AuthenticationStatusChanged(this.status);

  @override
  List<Object> get props => [status];
}

class AuthenticationUserChanged extends AuthenticationEvent {
  final Wallet wallet;

  const AuthenticationUserChanged(this.wallet);

  @override
  List<Object> get props => [wallet];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}

/// This event is used to request a login for a saved wallet profile.
///
/// This event will attempt to authenticate with the user's biometrics.
///
/// Will throw an exception if the user's biometrics are not available or
/// if the specified wallet profile does not exist. In that case, the user
/// will need to restore a wallet from the seed phrase.
class AuthenticationBiometricLoginRequested extends AuthenticationEvent {
  final String walletId;

  const AuthenticationBiometricLoginRequested(this.walletId);

  @override
  List<Object> get props => [walletId];
}

//TODO!.C: Wallet profile creation event? Should be in wallet profiles bloc?
//! Add wallet profile repository to authentication bloc? 