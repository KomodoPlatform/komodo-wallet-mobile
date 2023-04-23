import 'package:beamer/beamer.dart';
import 'package:komodo_dex/navigation/app_routes.dart';

abstract class AuthenticationGuard {
  static BeamGuard unauthenticated() {
    return BeamGuard(
      pathPatterns: ['*'],
      check: (context, location) {
        // TODO! Implement authentication check after auth bloc
        final isAuthenticated = true;

        return !isAuthenticated;
      },
      beamToNamed: (origin, target) => AppRoutes.portfolio.home(),
    );
  }

  /// This guard is used to redirect to the login page if the user is not
  /// authenticated. Matches all paths, so place only for routes that should
  /// be protected.
  static BeamGuard authenticated() {
    return BeamGuard(
      pathPatterns: ['*'],
      check: (context, location) {
        // TODO! Implement authentication check after auth bloc
        final isAuthenticated = false;

        return isAuthenticated;
      },
      beamToNamed: (origin, target) => AppRoutes.wallet.login(),
      onCheckFailed: (context, location) {
        // TODO: Implement handling/cleanup needed when user goes from
        // authenticated to unauthenticated state.
      },
    );
  }
}
