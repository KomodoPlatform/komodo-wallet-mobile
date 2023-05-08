import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/navigation/app_routes.dart';
import 'package:komodo_dex/packages/accounts/bloc/active_account_bloc.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';

@immutable
class AuthActiveAccountListener extends StatefulWidget {
  final Widget child;

  const AuthActiveAccountListener({Key? key, required this.child})
      : super(key: key);

  @override
  State<AuthActiveAccountListener> createState() =>
      _AuthActiveAccountListenerState();
}

class _AuthActiveAccountListenerState extends State<AuthActiveAccountListener> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listenWhen: authStateListenerCondition,
          listener: _handleAuthStateChange,
        ),
        BlocListener<ActiveAccountBloc, ActiveAccountState>(
          listenWhen: activeAccountStateListenerCondition,
          listener: _handleActiveAccountStateChange,
        ),
      ],
      child: widget.child,
    );
  }

  bool activeAccountStateListenerCondition(
      ActiveAccountState prevState, ActiveAccountState currentState) {
    return prevState != currentState &&
        currentState is ActiveAccountInitial &&
        context.read<AuthenticationBloc>().state.status ==
            AuthenticationStatus.authenticated;
  }

  bool authStateListenerCondition(
      AuthenticationState prevState, AuthenticationState currentState) {
    debugPrint('authStateListenerCondition');
    return prevState.status != currentState.status &&
        currentState.status == AuthenticationStatus.unauthenticated;
  }

  void _handleAuthStateChange(BuildContext context, AuthenticationState state) {
    debugPrint(
        '\nAuth state changed and AuthActiveAccountListener listened.\n');
    if (state.status == AuthenticationStatus.unauthenticated &&
        context.read<ActiveAccountBloc>().state is ActiveAccountInitial) {
      _navigateToInitialRoute(context);
    }
  }

  void _handleActiveAccountStateChange(
      BuildContext context, ActiveAccountState state) {
    debugPrint(
        '\nActive Account state changed and AuthActiveAccountListener listened.\n');
    if (state is ActiveAccountInitial &&
        context.read<AuthenticationBloc>().state.isAuthenticated) {
      _navigateToAccountsListPage(context);
    }
  }

  void _navigateToInitialRoute(BuildContext context) {
    Beamer.of(context).beamToNamed(AppRoutes.wallet.login());
  }

  void _navigateToAccountsListPage(BuildContext context) {
    Beamer.of(context).beamToNamed(AppRoutes.accounts.list());
  }
}
