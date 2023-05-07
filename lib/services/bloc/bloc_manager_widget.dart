import 'dart:async';
import 'dart:io';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/login/bloc/login_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/packages/pin_reset/bloc/pin_reset_bloc.dart';
import 'package:komodo_dex/packages/wallet_profiles/api/biometric_storage_api.dart';
import 'package:komodo_dex/packages/wallet_profiles/api/wallet_profile_adapter.dart';
import 'package:komodo_dex/packages/wallet_profiles/api/wallet_storage_hive_api.dart';
import 'package:komodo_dex/packages/wallet_profiles/bloc/wallet_profiles_bloc.dart';
import 'package:komodo_dex/packages/wallet_profiles/repository/wallet_repository.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

part 'bloc_manager.dart';

class BlocManagerWidget extends StatelessWidget {
  const BlocManagerWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // TODO.C: AppProviderManager taken from main.dart
    return MultiBlocProvider(
      providers: [
        // Instantiate all BLoCs here
        BlocProvider<LoginBloc>(
          create: (BuildContext context) => LoginBloc(
            prefs: BlocManager.instance._prefs,
            authenticationRepository:
                BlocManager.instance._authenticationRepository!,
          ),
        ),
        BlocProvider<PinResetBloc>(
          create: (BuildContext context) => PinResetBloc(
            prefs: BlocManager.instance._prefs,
            authenticationRepository:
                BlocManager.instance._authenticationRepository!,
          ),
        ),

        BlocProvider<WalletsBloc>(
          create: (BuildContext context) => WalletsBloc(
            walletRepository: BlocManager.instance._walletRepository,
          ),
        ),
        BlocProvider<AuthenticationBloc>(
          create: (BuildContext context) => AuthenticationBloc(
            authenticationRepository:
                BlocManager.instance._authenticationRepository!,
          ),
        ),
      ],
      child: child,
    );
  }
}
