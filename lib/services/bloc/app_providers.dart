import 'package:flutter/material.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:provider/provider.dart';

import '../../../app_config/app_config.dart';
import '../../../generic_blocs/authenticate_bloc.dart';
import '../../../model/addressbook_provider.dart';
import '../../../model/cex_provider.dart';
import '../../../model/feed_provider.dart';
import '../../../model/intent_data_provider.dart';
import '../../../model/multi_order_provider.dart';
import '../../../model/order_book_provider.dart';
import '../../../model/rewards_provider.dart';
import '../../../model/startup_provider.dart';
import '../../../model/swap_constructor_provider.dart';
import '../../../model/swap_provider.dart';
import '../../../model/updates_provider.dart';
import '../../../model/wallet_security_settings_provider.dart';

class AppProviderManager extends StatelessWidget {
  const AppProviderManager({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GenericBlocProvider<AuthenticateBloc>(
      bloc: AuthenticateBloc(),
      child: MultiProvider(
        child: child,
        providers: [
          ChangeNotifierProvider(
            create: (context) => SwapProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => OrderBookProvider(),
          ),
          if (appConfig.isFeedEnabled)
            ChangeNotifierProvider(
              create: (context) => FeedProvider(),
            ),
          ChangeNotifierProvider(
            create: (context) => RewardsProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => StartupProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UpdatesProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => CexProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => AddressBookProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => MultiOrderProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => IntentDataProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => ConstructorProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => walletSecuritySettingsProvider,
          )
        ],
      ),
    );
  }
}
