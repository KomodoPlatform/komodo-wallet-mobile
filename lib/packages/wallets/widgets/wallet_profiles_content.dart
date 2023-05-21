import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/common_widgets/app_logo.dart';
import 'package:komodo_dex/packages/create_wallet/widgets/create_wallet_button.dart';
import 'package:komodo_dex/packages/restore_wallet.dart/widgets/restore_wallet_button.dart';
import 'package:komodo_dex/packages/wallets/bloc/wallets_bloc.dart';
import 'package:komodo_dex/packages/wallets/state/wallets_state.dart';
import 'package:komodo_dex/packages/wallets/widgets/wallet_profile_tile.dart';

class WalletProfilesContent extends StatelessWidget {
  const WalletProfilesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<WalletsBloc>(
      context,
      listen: true,
    );

    final state = bloc.state as WalletsLoadSuccess;
    return Column(
      children: [
        SizedBox(height: 16),
        SizedBox(height: 160, child: AppLogo.full()),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CreateWalletButton(),
            SizedBox(width: 16),
            RestoreButton()
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          // ListView is wrapped in a Material widget to prevent the Ink of the
          // ListTile from being drawn beyond the ListView. This is a know
          // bug in Flutter: https://github.com/flutter/flutter/issues/86584
          child: Material(
            color: Colors.transparent,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              addRepaintBoundaries: false,
              itemCount: state.wallets.length,
              itemBuilder: (context, index) {
                final walletProfile = state.wallets[index];
                return WalletProfileTile(
                  key: Key('wallet-profile-tile-${walletProfile.walletId}'),
                  walletProfile: walletProfile,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String _welcomeAsset(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? 'assets/svg_light/welcome_wallet.svg'
          : 'assets/svg/welcome_wallet.svg';
}
