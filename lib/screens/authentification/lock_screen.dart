import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/common_widgets/app_logo.dart';
import 'package:komodo_dex/login/bloc/login_bloc.dart';
import 'package:komodo_dex/login/models/pin_type.dart';
import 'package:komodo_dex/login/screens/login_page.dart';
import 'package:komodo_dex/main.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:komodo_dex/packages/pin_reset/bloc/pin_reset_bloc.dart';
import 'package:komodo_dex/packages/pin_reset/events/index.dart';
import 'package:komodo_dex/packages/pin_reset/events/pin_setup_started.dart';
import 'package:komodo_dex/packages/pin_reset/pages/pin_reset_page.dart';
import '../../generic_blocs/authenticate_bloc.dart';
import '../../generic_blocs/camo_bloc.dart';
import '../../generic_blocs/coins_bloc.dart';
import '../../generic_blocs/main_bloc.dart';
import '../../localizations.dart';
import '../../model/startup_provider.dart';
import '../../model/updates_provider.dart';
import '../../model/wallet.dart';
import '../../model/wallet_security_settings_provider.dart';
import '../authentification/app_bar_status.dart';
import '../authentification/authenticate_page.dart';
import '../authentification/create_password_page.dart';
import '../authentification/pin_page.dart';
import '../authentification/unlock_wallet_page.dart';
import '../settings/updates_page.dart';
import '../../services/db/database.dart';
import '../../utils/log.dart';
import '../../utils/utils.dart';
import 'package:local_auth/local_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final bool isPinCreationInProgress =
        prefs.containsKey('is_pin_creation_in_progress');
    final Wallet? currentWallet =
        context.read<AuthenticationBloc>().state.wallet?.toLegacy();

    if (password == null && isPinCreationInProgress && currentWallet != null) {
      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => UnlockWalletPage(
                  isCreatedPin: true,
                  textButton: AppLocalizations.of(context)!.login,
                  wallet: currentWallet,
                  onSuccess: (String seed, String password) async {
                    setState(() {
                      this.password = password;
                    });
                    Navigator.of(context).pop();
                  },
                )),
      );
    }
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
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
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
    final StartupProvider startup = Provider.of<StartupProvider>(context);
    updatesProvider = Provider.of<UpdatesProvider>(context);
    final walletSecuritySettingsProvider =
        context.read<WalletSecuritySettingsProvider>();

    Widget _buildSplash({String? message}) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? 'assets/branding/logo_app_light.png'
                    : 'assets/branding/logo_app.png',
              ),
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
                          color: Theme.of(context).textTheme.caption!.color,
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

    if (!startup.live) {
      final RegExpMatch? _tailMatch =
          RegExp(r'([^\n\r]*)$').firstMatch(startup.log);
      final String? _logTail = _tailMatch == null ? '' : _tailMatch[0];
      return _buildSplash(message: _logTail);
    } else if (updatesProvider.status == null &&
        mainBloc.networkStatus == NetworkStatus.Online) {
      return _buildSplash();
    }

    return StreamBuilder<bool>(
      stream: authBloc.outIsLogin,
      initialData: authBloc.isLogin,
      builder: (BuildContext context, AsyncSnapshot<bool> isLogin) {
        return StreamBuilder<PinStatus>(
          initialData: authBloc.pinStatus,
          stream: authBloc.outpinStatus,
          builder:
              (BuildContext context, AsyncSnapshot<dynamic> outShowCreatePin) {
            if (outShowCreatePin.hasData &&
                outShowCreatePin.data == PinStatus.NORMAL_PIN) {
              if (isLogin.hasData && isLogin.data!) {
                return StreamBuilder<bool>(
                  initialData: authBloc.showLock,
                  stream: authBloc.outShowLock,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> outShowLock) {
                    if (outShowLock.hasData && outShowLock.data!) {
                      if (walletSecuritySettingsProvider
                          .activatePinProtection) {
                        return Stack(
                          children: <Widget>[
                            FutureBuilder<bool?>(
                              future: canCheckBiometrics,
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data &&
                                    widget.pinStatus == PinStatus.NORMAL_PIN) {
                                  Log.println('lock_screen:141', snapshot.data);
                                  if (isLogin.hasData && isLogin.data!) {
                                    authenticateBiometrics(
                                            context, widget.pinStatus)
                                        .then((_) {
                                      // If last login was camo and camo active value is kept,
                                      // then reset coin balance, this should happen only once
                                      // due to bio and camo between incompatible with each other
                                      if (camoBloc.isCamoActive) {
                                        camoBloc.isCamoActive = false;
                                        coinsBloc.resetCoinBalance();
                                      }
                                    });
                                  }
                                  return SizedBox();
                                }
                                return SizedBox();
                              },
                            ),
                            shouldUpdate
                                ? UpdatesPage(
                                    refresh: false,
                                    onSkip: () {
                                      setState(() {
                                        shouldUpdate = false;
                                      });
                                    },
                                  )
                                : BlocListener<LoginBloc, LoginState>(
                                    listenWhen: (previous, current) =>
                                        previous.submissionStatus !=
                                        current.submissionStatus,
                                    listener: (context, state) {
                                      if (state
                                          is LoginStatePinSubmittedSuccess) {
                                        if (widget.onSuccess != null) {
                                          widget.onSuccess!();
                                        }
                                      }
                                    },
                                    child: LoginPage(
                                        // title: AppLocalizations.of(context)!
                                        //     .lockScreen,
                                        // subTitle: AppLocalizations.of(context)!
                                        //     .enterPinCode,
                                        // pinStatus: widget.pinStatus,
                                        // isFromChangingPin: false,
                                        // onSuccess:
                                        //     widget.onSuccess as void Function()?,
                                        ),
                                  ),
                          ],
                        );
                      } else {
                        return shouldUpdate
                            ? UpdatesPage(
                                refresh: false,
                                onSkip: () {
                                  setState(() {
                                    shouldUpdate = false;
                                  });
                                },
                              )
                            : walletSecuritySettingsProvider
                                    .activateBioProtection
                                ? Stack(
                                    children: <Widget>[
                                      BiometricPage(
                                        pinStatus: widget.pinStatus,
                                      ),
                                    ],
                                  )
                                : widget.child!;
                      }
                    } else {
                      if (widget.child == null &&
                          (widget.pinStatus == PinStatus.DISABLED_PIN ||
                              widget.pinStatus ==
                                  PinStatus.DISABLED_PIN_BIOMETRIC))
                        return PinPage(
                          title: AppLocalizations.of(context)!.lockScreen,
                          subTitle: AppLocalizations.of(context)!.enterPinCode,
                          // pinStatus: widget.pinStatus,
                          // isFromChangingPin: false,
                        );
                      else
                        return widget.child!;
                    }
                  },
                );
              } else {
                return const AuthenticatePage();
              }
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                context.read<PinResetBloc>().add(
                      PinSetupStarted(
                        pinType: PinTypeName.normal,
                      ),
                    );
                final successMessage = await Navigator.push<String?>(
                  context,
                  PinResetPage.route,
                );
                if (successMessage != null) {
                  MyApp.rootScaffoldMessengerKey.currentState!.showSnackBar(
                    SnackBar(
                      content: Text(successMessage),
                    ),
                  );
                }
              });
              return Container(color: Colors.green);
              // return PinPage(
              //   title: AppLocalizations.of(context)!.createPin,
              //   subTitle: AppLocalizations.of(context)!.enterNewPinCode,
              //   // pinStatus: PinStatus.CREATE_PIN,
              //   password: password,
              //   // isFromChangingPin: false,
              // );
            }
          },
        );
      },
    );
  }
}

class BiometricPage extends StatefulWidget {
  const BiometricPage({
    Key? key,
    this.pinStatus,
    this.onSuccess,
  }) : super(key: key);

  final PinStatus? pinStatus;
  final Function? onSuccess;

  @override
  _BiometricPageState createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  IconData iconData = Icons.fingerprint;

  @override
  void initState() {
    canCheckBiometrics.then((bool? onValue) async {
      if (onValue! && (widget.pinStatus == PinStatus.NORMAL_PIN)) {
        final LocalAuthentication auth = LocalAuthentication();
        final List<BiometricType> availableBiometrics =
            await auth.getAvailableBiometrics();

        if (Platform.isIOS) {
          if (availableBiometrics.contains(BiometricType.face)) {
            setState(() {
              iconData = Icons.visibility;
            });
          }
        }
        authenticateBiometrics(context, widget.pinStatus);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStatus(
        context: context,
        pinStatus: PinStatus.NORMAL_PIN,
        title: AppLocalizations.of(context)!.fingerprint,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              size: 56,
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () =>
                  authenticateBiometrics(context, widget.pinStatus),
              child: Text(
                  AppLocalizations.of(context)!.authenticate.toUpperCase()),
            )
          ],
        ),
      ),
    );
  }
}
