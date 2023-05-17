// Credit to:
// https://github.com/slovnicki/beamer/tree/master/examples/authentication_bloc/lib/bloc

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_state.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/packages/authentication/repository/exceptions.dart';
import 'package:komodo_dex/packages/wallets/models/wallet.dart';
import 'package:komodo_dex/packages/wallets/repository/wallets_repository.dart';

export 'package:komodo_dex/packages/authentication/bloc/authentication_state.dart';

// export 'package:komodo_dex/packages/authentication/bloc/authentication_event.dart';

part 'authentication_event.dart';

class AuthenticationBloc
    extends HydratedBloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  final WalletsRepository _walletRepository;

  StreamSubscription<AuthenticationStatus>? _authenticationStatusSubscription;

  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
    required WalletsRepository walletRepository,
  })  : _authenticationRepository = authenticationRepository,
        _walletRepository = walletRepository,
        super(
          const AuthenticationState.unknown(),
        ) {
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(
        AuthenticationStatusChanged(status),
      ),
    );
    on<AuthenticationStatusChanged>((event, emit) async =>
        emit(await _mapAuthenticationStatusChangedtoState(event)));
    on<AuthenticationUserChanged>(
        (event, emit) => emit(_mapAuthenticationUserChangedToState(event)));
    on<AuthenticationLogoutRequested>(
        (event, emit) => _authenticationRepository.logOut());
    on<AuthenticationBiometricLoginRequested>(
        _handleAuthenticationBiometricLoginRequested);
  }

  void logout() => add(AuthenticationLogoutRequested());

  @override
  Future<void> close() {
    _authenticationStatusSubscription?.cancel();
    _authenticationRepository.dispose();
    return super.close();
  }

  void _handleAuthenticationBiometricLoginRequested(
    AuthenticationBiometricLoginRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    Wallet? wallet;
    emit(AuthenticationState.unauthenticated());
    try {
      final biometricsAvailable =
          await _authenticationRepository.canBiometricsAuthenticate();
      debugPrint('BIOMETRICS AVAILABLE: $biometricsAvailable');

      // TODO: Consider if/how it should be handled where we have the wallet
      // passphrase stored in biometric storage but the profile is not found.
      wallet = await _walletRepository.getWallet(event.walletId);

      //TODO: Remove after dev debugging
      final passphrase =
          await _authenticationRepository.getWalletPassphrase(event.walletId);

      debugPrint('GOT STORED PASSPHRASE: $passphrase');

      await _authenticationRepository.logInWithBiometrics(
        walletId: event.walletId,
      );
    } on WalletNotFoundException catch (_) {
      // This may be caused if the user has changed their bio-metrics since
      // storing the passphrase as all biometric data is invalidated when
      // a new fingerprint/pin is added or removed.
      emit(
        AuthenticationState.unauthenticated().withError(
          'Seed not found in device\'s secure storage. '
          'Try logging in with your seed.',
        ),
      );
      // TODO: Implement functionality to try sign in with seed if account
      // exists but passphrase is not found in biometric storage. We should
      // store some data in the wallet storage to validate that the passphrase
      // is associated with the wallet. Perhaps a hash checksum?
    } catch (e) {
      debugPrint('Exception type = ${e.runtimeType}');
      debugPrint('ERROR: $e');
    }
  }

  Future<AuthenticationState> _mapAuthenticationStatusChangedtoState(
    AuthenticationStatusChanged event,
  ) async {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        return const AuthenticationState.unauthenticated();
      case AuthenticationStatus.authenticated:
        final wallet = await _authenticationRepository.tryGetWallet();
        return wallet != null
            ? AuthenticationState.authenticated(wallet)
            : const AuthenticationState.unauthenticated();
      default:
        return const AuthenticationState.unknown();
    }
  }

  AuthenticationState _mapAuthenticationUserChangedToState(
          AuthenticationUserChanged event) =>
      event.wallet != null
          ? AuthenticationState.authenticated(event.wallet)
          : const AuthenticationState.unauthenticated();

  @override
  AuthenticationState fromJson(Map<String, dynamic> json) =>
      AuthenticationState.fromJson(json);

  @override
  Map<String, dynamic> toJson(AuthenticationState state) => state.toJson();
}
