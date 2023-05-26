// File containing routes to pages not yet migrated to new navigation system.

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/common_widgets/bottom_navbar_scaffold.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/portfolio/pages/portfolio_home_page.dart';
import 'package:komodo_dex/screens/dex/dex_page.dart';
import 'package:komodo_dex/screens/dex/orders/orders_page.dart';
import 'package:komodo_dex/screens/feed/feed_page.dart';
import 'package:komodo_dex/screens/markets/markets_page.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';

// TODO: Transition legacy pages' Nav 1.0 `push`/`pop`s to Nav 2.0 based Beamer
// nested locations.
// This file only adds them as top-level routes to the widget for each page.
// Once on the page, the page is responsible for it’s own sub-routes with
// Nav 1.0 pop and pushing. In the long-term, we should have all nested routes
// as a location in the new nav system so that we can easily navigate between
// parts of the app and create deep-links. This also allows us to restore the
// app's entire state using only the URL.

class LegacyAppBarLocations extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => [
        '/portfolio',
        '/dex',
        '/orders',
        '/markets',
        '/feed',
        '/settings',
      ];

  String portfolio() => '/portfolio';

  String dex() => '/dex';

  String orders() => '/orders';

  String markets() => '/markets';

  String feed() => '/feed';

  String settings() => '/settings';

  bool _isCurrentPath(String path) =>
      state.routeInformation.location?.contains(path) ?? false;

  bool _isCurrentPathAny(List<String> paths) => paths.any(_isCurrentPath);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      //
      if (_isCurrentPathAny([portfolio(), dex()]))
        BeamPage(
          type: BeamPageType.noTransition,
          key: const ValueKey('beamer-portfolio-page'),
          child: BottomNavbarScaffold(body: PortfolioHome()),
        ),

      //
      if (_isCurrentPath('dex'))
        BeamPage(
          // type: BeamPageType.noTransition,
          key: const ValueKey('beamer-dex-page'),
          child: DexPage(),
        ),

      //
      if (_isCurrentPath('markets'))
        BeamPage(
          key: const ValueKey('beamer-markets-page'),
          child: BottomNavbarScaffold(body: MarketsPage()),
          type: BeamPageType.noTransition,
        ),

      //
      if (_isCurrentPath('feed'))
        BeamPage(
          key: const ValueKey('beamer-feed-page'),
          child: BottomNavbarScaffold(
            body: FeedPage(),
            title: Text(AppLocalizations.of(context)!.feedTitle),
          ),
          type: BeamPageType.noTransition,
        ),

      //
      if (_isCurrentPath('settings'))
        BeamPage(
          key: const ValueKey('beamer-settings-page'),
          child: SettingPage(),
        ),

      //
      if (_isCurrentPath('orders'))
        BeamPage(
          key: const ValueKey('beamer-orders-page'),
          child: BottomNavbarScaffold(body: OrdersPage()),
          type: BeamPageType.noTransition,
        ),
    ];
  }
}
