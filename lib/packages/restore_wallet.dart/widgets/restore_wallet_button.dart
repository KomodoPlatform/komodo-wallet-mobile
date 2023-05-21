import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/welcome_page.dart';
import 'package:komodo_dex/widgets/box_button.dart';

// Credit for re-used legacy code from deleted file:
// lib/screens/authentification/authenticate_page.dart
// TODO: Reference new bloc if/when new "create wallet" bloc is created and
// reference new navigation path if/when migrate to new navigation system.
class CreateWalletButton extends StatelessWidget {
  const CreateWalletButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoxButton(
      key: const Key('createWalletButton'),
      text: Text(AppLocalizations.of(context)!.createAWallet),
      assetPath: Theme.of(context).brightness == Brightness.light
          ? 'assets/svg_light/create_wallet.svg'
          : 'assets/svg/create_wallet.svg',
      onPressed: () => Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const WelcomePage()),
      ),
    );
  }
}
