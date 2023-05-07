import 'package:beamer/beamer.dart';
import 'package:komodo_dex/navigation/app_routes.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:provider/provider.dart';

class AuthenticationGuard {
  static BeamGuard unauthenticated() {
    return BeamGuard(
      pathPatterns: ['*'],
      check: (context, location) {
        final isAuthenticated =
            context.read<AuthenticationBloc>().state.isAuthenticated;
        final canAccess = !isAuthenticated;

        return canAccess;
      },
      beamToNamed: (origin, target) => AppRoutes.accounts.accounts(),
    );
  }

  /// This guard is used to redirect to the login page if the user is not
  /// authenticated. Matches all paths, so place only for routes that should
  /// be protected.
  static BeamGuard authenticated() {
    return BeamGuard(
      pathPatterns: ['*'],
      check: (context, location) {
        final isAuthenticated =
            context.read<AuthenticationBloc>().state.isAuthenticated;
        final canAccess = isAuthenticated;

        return canAccess;
      },
      beamToNamed: (origin, target) => AppRoutes.wallet.login(),
      onCheckFailed: (context, location) {
        // TODO: Implement handling/cleanup needed when user goes from
        // authenticated to unauthenticated state.
      },
    );
  }
}
