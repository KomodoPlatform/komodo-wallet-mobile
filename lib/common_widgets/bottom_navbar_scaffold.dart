import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/common_widgets/bottom_navigation_bar.dart';
import 'package:komodo_dex/drawer/drawer.dart';
import 'package:komodo_dex/drawer/drawer_bloc.dart';

class BottomNavbarScaffold extends StatelessWidget {
  const BottomNavbarScaffold({
    Key? key,
    required this.body,
  }) : super(key: key);

  final Widget body;

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
