import 'dart:async';

import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/login/exceptions/auth_exceptions.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

// TODO: Migrate parts of the application referencing the legacy coins/auth
// blocs for authentication to a new AuthenticationBloc which listens to
// the stream of authentication events from this repository.

/// Repository for handling authentication logic. This repository is
/// responsible for handling all authentication logic and should be used
/// instead of the legacy authentication blocs. NB that this repository is
/// not a singleton and should be instantiated and passed to blocs.
class AuthenticationRepository {
  AuthenticationRepository({
    required this.prefs,
    required Database sqlDB,
    required MMService marketMakerService,
  })  : _sqlDB = sqlDB,
        _marketMakerService = marketMakerService;

  bool _isInitialized = false;

  final SharedPreferences prefs;

  final Database _sqlDB;

  final MMService _marketMakerService;

  AuthenticationStatus? _lastAuthState;

  late final StreamSubscription<AuthenticationStatus> _subscription;

  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    yield* _controller.stream;
  }

  AppLocalizations loc = AppLocalizations();

  /// Method for initializing the authentication repository. This method
  Future<void> init() async {
    if (_isInitialized)
      return Future.error(
        Exception('AuthenticationRepository is already initialized'),
      );

    _subscription = status.listen(
      (AuthenticationStatus status) {
        _lastAuthState = status;
      },
    );

    // Add any initialization logic migrated from the legacy blocs here

    // Set initialized
    _isInitialized = true;
  }

  bool get _isAuthenticated =>
      _lastAuthState == AuthenticationStatus.authenticated;

  Future<void> logInWithPassphrase({
    required String walletId,
    required String passphrase,
  }) async {
    // TODO! Implement this method

    // 1. Check if the wallet exists
    // 2. Check if the passphrase is correct
    // 3. If so, set the wallet as the active wallet
    // 4. Start the market maker service
    // 5. Set the authentication status to authenticated

    _controller.add(AuthenticationStatus.authenticated);
  }

  Future<bool> biometricsAvailable() async {
    // TODO: implement getBioProtection
    throw UnimplementedError();
  }

  // Internal method to ensure the user is signed in. If not, an exception is
  // thrown.
  void _ensureSignedIn() async {
    if (!_isAuthenticated) {
      return Future.error(
        NotAuthenticatedException('User is not signed in.'),
      );
    }
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
    // TODO: Call API to log out and do any other necessary cleanup.
  }

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
