import 'package:flutter/material.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/model/updates_provider.dart';
import 'package:komodo_dex/widgets/build_red_dot.dart';
import 'package:provider/provider.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Refactor from legacy bloc
    final FeedProvider? feedProvider =
        appConfig.isFeedEnabled ? Provider.of<FeedProvider>(context) : null;
    final UpdatesProvider updatesProvider =
        Provider.of<UpdatesProvider>(context);

    return BottomNavigationBar(
      // TODO: Refactor to integrate with beamer router
      type: BottomNavigationBarType.fixed,
      // TODO: Refactor to integrate with beamer router
      // onTap: onTabTapped,
      onTap: (_) => throw UnimplementedError(),
      // TODO: Refactor to integrate with beamer router
      // currentIndex: indexTab!,
      elevation: 0,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: const Icon(
              Icons.account_balance_wallet,
              key: Key('main-nav-portfolio'),
            ),
            label: AppLocalizations.of(context)!.portfolio),
        BottomNavigationBarItem(
            icon: const Icon(Icons.swap_vert, key: Key('main-nav-dex')),
            label: AppLocalizations.of(context)!.dex),
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.show_chart,
            key: Key('main-nav-markets'),
          ),
          label: AppLocalizations.of(context)!.marketsTab,
        ),
        if (appConfig.isFeedEnabled)
          BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  const Icon(Icons.library_books, key: Key('main-nav-feed')),
                  if (feedProvider!.hasNewItems) buildRedDot(context),
                ],
              ),
              label: AppLocalizations.of(context)!.feedTab),
        BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                const Icon(Icons.dehaze, key: Key('main-nav-more')),
                if (updatesProvider.status != UpdateStatus.upToDate)
                  buildRedDot(context),
              ],
            ),
            label: AppLocalizations.of(context)!.moreTab),
      ],
    );
  }
}
