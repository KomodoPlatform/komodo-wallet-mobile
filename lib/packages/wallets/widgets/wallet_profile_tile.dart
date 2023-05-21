import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:komodo_dex/packages/wallets/models/wallet.dart';
import 'package:komodo_dex/utils/utils.dart';

class WalletProfileTile extends StatelessWidget {
  final Wallet walletProfile;

  const WalletProfileTile({
    Key? key,
    required this.walletProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.3)
              : Colors.white.withOpacity(0.6),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        tileColor: Theme.of(context).colorScheme.primaryContainer,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        onTap: () {
          context.read<AuthenticationBloc>().add(
                AuthenticationBiometricLoginRequested(walletProfile.walletId),
              );
        },
        leading: CircleAvatar(
          // radius: 30,
          backgroundColor: walletProfile.color,
          child: Center(
            child: Text(
              walletProfile.name.initials(2),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
        ),
        title: Text(
          walletProfile.name,
          // style: Theme.of(context).textTheme.body,
        ),
      ),
    );
  }
}
