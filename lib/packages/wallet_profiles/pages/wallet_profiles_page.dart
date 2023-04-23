import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komodo_dex/common_widgets/app_logo.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/wallet_profiles/bloc/wallet_profiles_bloc.dart';
import 'package:komodo_dex/packages/wallet_profiles/events/wallet_profiles_load_requested.dart';
import 'package:komodo_dex/packages/wallet_profiles/state/wallet_profiles_state.dart';
import 'package:komodo_dex/packages/wallet_profiles/widgets/wallet_profile_tile.dart';
import 'package:komodo_dex/packages/wallet_profiles/widgets/wallet_profiles_content.dart';
// import '../authentification/new_account_page.dart';
// import '../settings/restore_seed_page.dart';

class WalletProfilesPage extends StatefulWidget {
  const WalletProfilesPage();

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const WalletProfilesPage());
  }

  @override
  _WalletProfilesPageState createState() => _WalletProfilesPageState();
}

class _WalletProfilesPageState extends State<WalletProfilesPage> {
  TextEditingController controller = TextEditingController();
  bool isButtonLoginEnabled = false;

  late WalletProfilesBloc _walletProfilesBloc;

  @override
  void initState() {
    // This bloc reference can be removed when the FAB is removed. We want to
    // avoid listening to a bloc in a parent widget which does not rely
    // on the state to avoid unnecessary rebuilds.
    _walletProfilesBloc =
        BlocProvider.of<WalletProfilesBloc>(context, listen: false);

    // _walletProfilesBloc.testingRemoveAllWallets();

    super.initState();
    _walletProfilesBloc.add(
      WalletProfilesLoadRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _walletProfilesBloc = BlocProvider.of<WalletProfilesBloc>(
      context,
      listen: true,
    );
    final _state = _walletProfilesBloc.state;
    return Scaffold(
      // FAB Used for mockup testing to create new wallet. Remove later.
      floatingActionButton: _state is! WalletProfilesLoadSuccess
          ? null
          : FloatingActionButton(
              onPressed: () {
                // _walletProfilesBloc.state as WalletProfilesLoadSuccess;

                _walletProfilesBloc.testingAddWallet(
                  WalletProfile(
                    id: (_state.wallets.length + 1).toString(),
                    name: "Wallet ${_state.wallets.length + 1}",
                  ),
                );
              },
            ),
      body: BlocBuilder<WalletProfilesBloc, WalletProfilesState>(
        builder: (context, state) {
          final bool showLoading = state is WalletProfilesLoadInProgress ||
              state is WalletProfilesInitial;

          if (showLoading)
            // return Center(child: CircularProgressIndicator());
            return Center(
              child: SizedBox(
                height: 60,
                child: AppLogo.full(color: false),
              ),
            );
          else if (state is WalletProfilesLoadFailure) {
            return Center(
              child: Text(state.errorMessage),
            );
          } else if (state is WalletProfilesLoadSuccess) {
            return WalletProfilesContent();
          }
          return Center(
            child: Text(AppLocalizations.of(context)!.errorTryLater),
          );
        },
      ),
    );
  }

  // TODO: Handle button to create new wallet. Navigate to the page for creating
  // a new wallet. It is multiple steps.

  // TODO: Handle button to try sign into existing wallet using passphrase.
}
