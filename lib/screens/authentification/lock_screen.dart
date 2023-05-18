import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/common_widgets/app_logo.dart';
import 'package:komodo_dex/packages/accounts/bloc/active_account_bloc.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generic_blocs/authenticate_bloc.dart';
import '../../generic_blocs/main_bloc.dart';
import '../../model/startup_provider.dart';
import '../../model/updates_provider.dart';
import '../../model/wallet.dart';
import '../../model/wallet_security_settings_provider.dart';
import '../../utils/log.dart';
import '../../utils/utils.dart';
import '../authentification/create_password_page.dart';
import '../settings/updates_page.dart';

/// Protective layer: MyApp | LockScreen | MyHomePage.
/// Also handles the application startup.
class LockScreen extends StatefulWidget {
  const LockScreen({
    Key? key,
    this.pinStatus = PinStatus.NORMAL_PIN,
    this.child,
    this.onSuccess,
    required this.context,
  }) : super(key: key);

  final PinStatus pinStatus;
  final Widget? child;
  final Function? onSuccess;
  final BuildContext context;

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String? password;
  bool isInitPassword = false;
  late UpdatesProvider updatesProvider;
  bool shouldUpdate = false;

  Future<void> _initScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    Log('lock_screen connectivity: ]', result.toString());
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        mainBloc.setNetworkStatus(NetworkStatus.Online);
        break;
      case ConnectivityResult.none:
        mainBloc.setNetworkStatus(NetworkStatus.Offline);
        break;
      default:
        mainBloc.setNetworkStatus(NetworkStatus.Offline);
        break;
    }
  }

  Future<void> initConnectivity() async {
    try {
      await _connectivitySubscription?.cancel();
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    } on PlatformException catch (e) {
      Log('lock_screen connectivity: ]', '$e');
      return Future.error(e);
    }
    Log('lock_screen connectivity: ]',
        'initConnectivity: $_updateConnectionStatus');
  }

  @override
  void initState() {
    super.initState();
    final ScreenArguments? args =
        ModalRoute.of(widget.context)!.settings.arguments as ScreenArguments?;
    password = args?.password;
    _initScreen();

    initConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      pinScreenOrientation(context);

      if (updatesProvider.status == null &&
          mainBloc.networkStatus == NetworkStatus.Online) {
        await updatesProvider.check();
      }
      setState(() {
        shouldUpdate = updatesProvider.status == UpdateStatus.recommended ||
            updatesProvider.status == UpdateStatus.required;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedWallet = context.select<AuthenticationBloc, Wallet?>(
        (bloc) => bloc.state.wallet?.toLegacy());

    final accountBlocState = context.watch<ActiveAccountBloc>().state;

    final activeAccount = accountBlocState.activeAccount;

    final StartupProvider startup = Provider.of<StartupProvider>(context);
    updatesProvider = Provider.of<UpdatesProvider>(context);

    if (shouldUpdate)
      return UpdatesPage(
        refresh: false,
        onSkip: () {
          setState(() {
            shouldUpdate = false;
          });
        },
      );

    final RegExpMatch? tailMatch =
        RegExp(r'([^\n\r]*)$').firstMatch(startup.log);
    final String? logTail = tailMatch == null ? '' : tailMatch[0];

    // TODO: Listen for Authentication and ActiveAccount bloc errors and handle
    // appropriately.

    // TODO: Handle the case where we have pending A-Dex API actions and the
    // user has a pending account swich. We should show a loading screen until
    // the pending account switch is complete.

    final bool isAccountSwitching =
        accountBlocState is ActiveAccountSwitchInProgress;

    if (isAccountSwitching || activeAccount == null || !startup.live)
      return _buildSplash(message: logTail);

    return widget.child!;
  }

  Widget _buildSplash({String? message}) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox.square(dimension: 80, child: AppLogo.icon()),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 20),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                if (message != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const Widget _defaultChild = !kDebugMode
      ? SizedBox()
      : DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.red,
                Colors.blue,
              ],
            ),
          ),
          child: Text('Oops... You are not supposed to see this!'),
        );
}
