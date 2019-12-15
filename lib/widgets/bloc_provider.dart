// Generic Interface for all BLoCs
import 'package:flutter/material.dart';

abstract class BlocBase {
  void dispose();
}

// Generic BLoC provider
class BlocProvider<T extends BlocBase> extends StatefulWidget {
  const BlocProvider({
    Key key,
    @required this.child,
    @required this.bloc,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context) {
    /* For Flutter v1.12.13
    final BlocProvider<T> provider = context.findAncestorWidgetOfExactType<BlocProvider<T>>();
    */

    // For Flutter v1.9.1:
    final Type type = _typeOf<BlocProvider<T>>();
    final BlocProvider<T> provider = context.ancestorWidgetOfExactType(type);

    return provider.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BlocProviderState<T> extends State<BlocProvider<BlocBase>> {
  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
