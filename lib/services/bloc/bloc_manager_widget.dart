import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/login/bloc/login_bloc.dart';
import 'package:komodo_dex/packages/authentication_repository/authentication_repository.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            prefs: BlocManager()._prefs,
            authenticationRepository: BlocManager()._authenticationRepository,
          ),
        ),
      ],
      child: child,
    );
  }
}
