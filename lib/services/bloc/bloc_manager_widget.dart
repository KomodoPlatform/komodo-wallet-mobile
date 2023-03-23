import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/login/bloc/login_bloc.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../authentication/repository/authentication_repository.dart';

part 'bloc_manager.dart';

class BlocManagerWidget extends StatelessWidget {
  const BlocManagerWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Instantiate all BLoCs here
        BlocProvider<LoginBloc>(
          create: (BuildContext context) => LoginBloc(
            prefs: BlocManager.instance._prefs,
            loginRepository: BlocManager.instance._authenticationRepository,
          ),
        ),
        BlocProvider<PinResetBloc>(
          create: (BuildContext context) => PinResetBloc(
            prefs: BlocManager.instance._prefs,
            loginRepository: BlocManager.instance._authenticationRepository!,
          ),
        ),
      ],
      child: child,
    );
  }
}
