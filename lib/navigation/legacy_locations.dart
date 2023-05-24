// File containing routes to pages not yet migrated to new navigation system.

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/common_widgets/bottom_navigation_bar.dart';
import 'package:komodo_dex/drawer/drawer.dart';
import 'package:komodo_dex/common_widgets/bottom_navbar_scaffold.dart';
import 'package:komodo_dex/screens/dex/dex_page.dart';
import 'package:komodo_dex/screens/feed/feed_page.dart';
import 'package:komodo_dex/screens/markets/markets_page.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';

class LegacyAppBarLocations extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => [
        '/portfolio',
        '/dex',
        '/markets',
        '/feed',
        '/settings',
      ];

  String portfolio() => '/portfolio';

  String dex() => '/dex';

  String markets() => '/markets';

  String feed() => '/feed';

  String settings() => '/settings';

  bool _doesCurrentLocationContain(String path) =>
      state.routeInformation.location?.contains(path) ?? false;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      //
      if (_doesCurrentLocationContain('portfolio'))
        BeamPage(
          type: BeamPageType.noTransition,
          key: const ValueKey('beamer-portfolio-page'),
          child: BottomNavbarScaffold(body: CoinsPage()),
        ),

      //
      if (_doesCurrentLocationContain('dex'))
        BeamPage(
          type: BeamPageType.noTransition,
          key: const ValueKey('beamer-dex-page'),
          child: BottomNavbarScaffold(body: DexPage()),
        ),

      //
      if (_doesCurrentLocationContain('markets'))
        BeamPage(
          key: const ValueKey('beamer-markets-page'),
          child: BottomNavbarScaffold(body: MarketsPage()),
          type: BeamPageType.noTransition,
        ),

      //
      if (_doesCurrentLocationContain('feed'))
        BeamPage(
          key: const ValueKey('beamer-feed-page'),
          child: BottomNavbarScaffold(body: FeedPage()),
          type: BeamPageType.noTransition,
        ),

      //
      if (_doesCurrentLocationContain('settings'))
        BeamPage(
          key: const ValueKey('beamer-settings-page'),
          type: BeamPageType.noTransition,
          child: SettingPage(),
        ),
    ];
  }
}
