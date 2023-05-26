import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/common_widgets/bottom_navigation_bar.dart';
import 'package:komodo_dex/drawer/drawer.dart';
import 'package:komodo_dex/drawer/drawer_bloc.dart';

class BottomNavbarScaffold extends StatelessWidget {
  const BottomNavbarScaffold({
    required this.body,
    this.appBar,
    this.title,
    super.key,
  }) : assert(
          !(title != null && appBar != null),
          'You cannot provide both a title and an appBar'
          ' to BottomNavbarScaffold.',
        );

  final Widget body;
  final AppBar? appBar;
  final Text? title;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return BlocConsumer<DrawerBloc, DrawerState>(
      listener: (context, state) {
        final bool isDrawerOpen = state is DrawerOpenState;

        if (isDrawerOpen) {
          scaffoldKey.currentState?.openEndDrawer();
        } else {
          scaffoldKey.currentState?.closeEndDrawer();
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: scaffoldKey,
          appBar: appBar ?? (title != null ? AppBar(title: title) : null),
          body: body,
          endDrawer: AppDrawer(),
          bottomNavigationBar: AppBottomNavigationBar(
            key: const ValueKey('app-bottom-navigation-bar'),
          ),
          onEndDrawerChanged: (wasOpened) {
            final bool isDrawerOpen = state is DrawerOpenState;

            // Don't report a state change if the drawer is already in the
            // correct state.
            if (isDrawerOpen == wasOpened) return;

            BlocProvider.of<DrawerBloc>(context)
                .add(wasOpened ? DrawerOpened() : DrawerClosed());
          },
        );
      },
    );
  }
}
