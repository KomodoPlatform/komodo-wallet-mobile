// Generic Interface for all BLoCs
import 'package:flutter/material.dart';

abstract class GenericBlocBase {
  void dispose();
}

// Generic BLoC provider
class GenericBlocProvider<T extends GenericBlocBase> extends StatefulWidget {
  const GenericBlocProvider({
    Key? key,
    required this.child,
    required this.bloc,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _GenericBlocProviderState<T> createState() => _GenericBlocProviderState<T>();

  static T of<T extends GenericBlocBase>(BuildContext context) {
    final GenericBlocProvider<T> provider =
        context.findAncestorWidgetOfExactType<GenericBlocProvider<T>>()!;
    return provider.bloc;
  }
}

class _GenericBlocProviderState<T>
    extends State<GenericBlocProvider<GenericBlocBase>> {
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
