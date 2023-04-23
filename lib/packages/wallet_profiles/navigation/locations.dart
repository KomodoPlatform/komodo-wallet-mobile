import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/wallet_profiles/pages/wallet_profiles_page.dart';

class WalletProfilesLocation extends BeamLocation {
  @override
  List<String> get pathPatterns => ['/login', '/wallets', '/'];

  @override
  List<BeamPage> buildPages(
      BuildContext context, RouteInformationSerializable<dynamic> state) {
    return [
      BeamPage(
        key: const ValueKey('wallet_profiles'),
        child: WalletProfilesPage(),
      ),
    ];
  }
}
