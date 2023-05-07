import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/authentication/navigation/authentication_guard.dart';
import 'package:komodo_dex/packages/wallets/pages/wallets_page.dart';

class WalletsLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/login', '/wallets', '/'];

  @override
  List<BeamGuard> get guards => [AuthenticationGuard.unauthenticated()];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        key: const ValueKey('wallets-beam-page'),
        child: WalletsPage(),
      ),
    ];
  }
}
