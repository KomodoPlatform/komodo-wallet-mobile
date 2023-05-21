import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/common_widgets/app_logo.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/navigation/app_routes.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:komodo_dex/packages/wallets/bloc/wallets_bloc.dart';
import 'package:komodo_dex/packages/wallets/events/wallets_load_requested.dart';
import 'package:komodo_dex/packages/wallets/models/wallet.dart';
import 'package:komodo_dex/packages/wallets/state/wallets_state.dart';
import 'package:komodo_dex/packages/wallets/widgets/quick_create_wallet_button.dart';
import 'package:komodo_dex/packages/wallets/widgets/wallet_profiles_content.dart';
import 'package:uuid/uuid.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage();

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const WalletsPage());
  }

  @override
  _WalletsPageState createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  TextEditingController controller = TextEditingController();
  bool isButtonLoginEnabled = false;

  late WalletsBloc _walletProfilesBloc;

  @override
  void initState() {
    // This bloc reference can be removed when the FAB is removed. We want to
    // avoid listening to a bloc in a parent widget which does not rely
    // on the state to avoid unnecessary rebuilds.
    _walletProfilesBloc = BlocProvider.of<WalletsBloc>(context, listen: false);

    // _walletProfilesBloc.testingRemoveAllWallets();

    BlocProvider.of<WalletsBloc>(context).add(WalletsLoadRequested());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _walletProfilesBloc = BlocProvider.of<WalletsBloc>(
      context,
      listen: true,
    );

    final _state = _walletProfilesBloc.state;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listenWhen: _listenWhenAuthStateChanged,
          listener: _onAuthStateChanged,
        ),
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listenWhen: _listenWhenNewAuthError,
          listener: _onNewAuthError,
        ),
      ],
      child: Scaffold(
        // FAB Used for mockup testing to create new wallet. Remove later.
        floatingActionButton:
            _state is! WalletsLoadSuccess ? null : QuickCreateWalletButton(),
        body: BlocBuilder<WalletsBloc, WalletsState>(
          builder: (context, state) {
            final bool showLoading =
                state is WalletsLoadInProgress || state is WalletsInitial;

            if (showLoading)
              // return Center(child: CircularProgressIndicator());
              return Center(
                child: SizedBox(
                  height: 60,
                  child: AppLogo.full(color: false),
                ),
              );
            else if (state is WalletsLoadFailure) {
              return Center(
                child: Text(state.errorMessage),
              );
            } else if (state is WalletsLoadSuccess) {
              return WalletProfilesContent();
            }
            return Center(
              child: Text(AppLocalizations.of(context)!.errorTryLater),
            );
          },
        ),
      ),
    );
  }

  bool _listenWhenAuthStateChanged(
      AuthenticationState previous, AuthenticationState current) {
    return previous.isAuthenticated != current.isAuthenticated;
  }

  void _onAuthStateChanged(BuildContext context, AuthenticationState state) {
    debugPrint('WalletsPage._onAuthenticationStateChanged');
    if (state.isAuthenticated) {
      Beamer.of(context).beamToNamed(
        AppRoutes.accounts.list(),
        replaceRouteInformation: true,
      );
    }
  }

  bool _listenWhenNewAuthError(
      AuthenticationState previous, AuthenticationState current) {
    return current.hasError && previous.error != current.error;
  }

  void _onNewAuthError(BuildContext context, AuthenticationState state) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content:
              Text(state.error ?? AppLocalizations.of(context)!.errorTryAgain),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // TODO: Handle button to create new wallet. Navigate to the page for creating
  // a new wallet. It is multiple steps.

  // TODO: Handle button to try sign into existing wallet using passphrase.
}
