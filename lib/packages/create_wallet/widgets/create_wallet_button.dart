import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/welcome_page.dart';
import 'package:komodo_dex/widgets/box_button.dart';

// Credit for re-used legacy code from deleted file:
// lib/screens/authentification/authenticate_page.dart
// TODO: Reference new bloc if/when new restore wallet bloc is created.

class RestoreButton extends StatelessWidget {
  const RestoreButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoxButton(
      key: const Key('restoreWallet'),
      text: Text(AppLocalizations.of(context)!.restoreWallet),
      assetPath: Theme.of(context).brightness == Brightness.light
          ? 'assets/svg_light/lock_off.svg'
          : 'assets/svg/lock_off.svg',
      onPressed: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const WelcomePage(
              isFromRestore: true,
            ),
          ),
        );
      },
    );
  }
}
