import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/atomicdex_api/src/config/atomicdex_api_config.dart';
import 'package:komodo_dex/login/bloc/login_bloc.dart';
import 'package:komodo_dex/migration_manager/migration_manager.dart';
import 'package:komodo_dex/migration_manager/migrations/multi_account_migration.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/packages/accounts/bloc/account_form_bloc.dart';
import 'package:komodo_dex/packages/accounts/bloc/accounts_list_bloc.dart';
import 'package:komodo_dex/packages/accounts/bloc/active_account_bloc.dart';
import 'package:komodo_dex/packages/accounts/repository/account_repository.dart';
import 'package:komodo_dex/packages/accounts/repository/active_account_repository.dart';
import 'package:komodo_dex/packages/app/widgets/placeholder_bloc.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/packages/pin_reset/bloc/pin_reset_bloc.dart';
import 'package:komodo_dex/packages/wallets/api/wallet_storage_api.dart';
import 'package:komodo_dex/packages/wallets/bloc/wallets_bloc.dart';
import 'package:komodo_dex/packages/wallets/repository/wallets_repository.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/db/legacy_db_adapter.dart';
import 'package:komodo_dex/services/mm_service.dart';
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
            walletRepository: BlocManager.instance._walletRepository,
            authenticationRepository:
                BlocManager.instance._authenticationRepository!,
          ),
        ),

        BlocProvider<AccountFormBloc>(
          create: (BuildContext context) => AccountFormBloc(
            accountRepository: BlocManager.instance._accountRepository,
            authenticationRepository:
                BlocManager.instance._authenticationRepository!,
          ),
        ),

        BlocProvider<AccountsListBloc>(
          create: (BuildContext context) => AccountsListBloc(
            accountRepository: BlocManager.instance._accountRepository,
          ),
        ),

        BlocProvider<ActiveAccountBloc>(
          create: (BuildContext context) => ActiveAccountBloc(
            activeAccountRepository:
                BlocManager.instance._activeAccountRepository,
            accountRepository: BlocManager.instance._accountRepository,
          ),
        ),

        BlocProvider<PlaceholderBloc>(
          create: (BuildContext context) => PlaceholderBloc(),
        ),
      ],
      child: child,
    );
  }
}
