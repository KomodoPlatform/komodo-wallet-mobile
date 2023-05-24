import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';

class PortfolioLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/portfolio'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(key: const ValueKey('portfolio'), child: CoinsPage()),
    ];
  }
}
