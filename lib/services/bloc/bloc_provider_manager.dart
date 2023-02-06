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
        // Instantiate all BLoCs here
        // TODO: Remove this sample bloc after first bloc is added. This is here
        // to prevent the analyzer from complaining about an empty list.
        BlocProvider<_SampleBloc>(
          create: (BuildContext context) => _SampleBloc(),
        ),
      ],
      child: child,
    );
  }
}

class _SampleBloc extends Bloc<_SampleEvent, _SampleState> {
  _SampleBloc() : super(_SampleState());
}

class _SampleState {}

class _SampleEvent {}
