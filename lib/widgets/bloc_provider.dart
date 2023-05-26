// Generic Interface for all BLoCs
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Generic BLoC provider
abstract class GenericBlocBase {
  void dispose();
}

class GenericBlocProvider<T extends GenericBlocBase> extends InheritedWidget {
  const GenericBlocProvider({
    required super.child,
    required this.bloc,
    super.key,
  });

  final T bloc;

  static T of<T extends GenericBlocBase>(BuildContext context) {
    final GenericBlocProvider<T>? provider =
        context.findAncestorWidgetOfExactType<GenericBlocProvider<T>>();
    return provider!.bloc;
  }

  @override
  bool updateShouldNotify(GenericBlocProvider<T> oldWidget) =>
      oldWidget.bloc != bloc;
}
