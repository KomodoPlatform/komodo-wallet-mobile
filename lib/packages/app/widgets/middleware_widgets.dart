import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/packages/app/widgets/placeholder_bloc.dart';

/// Widget that sits between the MaterialApp and the route builder of the
/// MaterialApp. This is created because we do not have access to the
/// localizations above the MaterialApp.router.
///
/// This can be used for widgets that need to be build regardless of the
/// current route. This can also be used for widgets that need to listen to
/// changes in the app state.
///
/// Widget tree:
/// BeamerProvider -> MaterialApp.router -> MiddlewareWidgets
/// -> MaterialApp.router builder
class MiddlewareWidgets extends StatelessWidget {
  final Widget child;

  MiddlewareWidgets({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      key: Key('app-middleware-BlocListener'),
      listeners: _blocListeners,
      child: Stack(
        children: [
          Positioned.fill(
            key: Key('app-middleware-child'),
            child: child,
          ),
          // Overlay widgets go here
        ],
      ),
    );
  }

  List<BlocListener> get _blocListeners => [
        // Listeners go here. Define the listener elsewhere and add it here
        // instead of writing the full code here.
        _placeholderListener,
      ];

  final _placeholderListener = BlocListener<PlaceholderBloc, PlaceholderState>(
    listener: (context, state) {},
  );
}
