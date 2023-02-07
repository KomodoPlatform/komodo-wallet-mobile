import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/packages/login/bloc/login_bloc.dart';

class BlocProviderWidget extends StatelessWidget {
  const BlocProviderWidget({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Instantiate all BLoCs here
        BlocProvider<LoginBloc>(
          create: (BuildContext context) => LoginBloc(),
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
