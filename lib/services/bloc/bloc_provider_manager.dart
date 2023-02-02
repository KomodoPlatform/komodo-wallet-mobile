import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocProviderManager extends StatelessWidget {
  const BlocProviderManager({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // TODO: Instantiate all BLoCs here
        // BlocProvider(
        //   create: (context) => SubjectBloc(),
        // ),
        // BlocProvider(
        //   create: (context) => SubjectBloc(),
        // ),
      ],
      child: child,
    );
  }
}
