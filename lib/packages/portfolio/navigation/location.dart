import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/portfolio/pages/portfolio_home.dart';
import 'package:komodo_dex/packages/wallet_profiles/pages/wallet_profiles_page.dart';

class PortfolioLocation extends BeamLocation {
  @override
  List<String> get pathPatterns => ['/portfolio'];

  @override
  List<BeamPage> buildPages(
      BuildContext context, RouteInformationSerializable<dynamic> state) {
    return [
      BeamPage(
        key: const ValueKey('portfolio'),
        child: PortfolioHome(),
      ),
    ];
  }
}
