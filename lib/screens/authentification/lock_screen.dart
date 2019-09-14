import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/authentification/authenticate_page.dart';
import 'package:komodo_dex/screens/authentification/create_password_page.dart';
import 'package:komodo_dex/screens/authentification/pin_page.dart';
import 'package:komodo_dex/screens/authentification/unlock_wallet_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockScreen extends StatefulWidget {
  const LockScreen(
      {this.pinStatus = PinStatus.NORMAL_PIN,
      this.child,
      this.onSuccess,
      @required this.context});

  final PinStatus pinStatus;
  final Widget child;
  final Function onSuccess;
  final BuildContext context;

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String password;
  bool isInitPassword = false;

  Future<void> _initScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isPinIsCreated = prefs.getBool('isPinIsCreated');
    final Wallet currentWallet = await DBProvider.db.getCurrentWallet();

    if (password == null &&
        isPinIsCreated != null &&
        isPinIsCreated == true &&
        currentWallet != null) {
      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => UnlockWalletPage(
                  isCreatedPin: true,
                  textButton: AppLocalizations.of(context).login,
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

  @override
  void initState() {
    final ScreenArguments args =
        ModalRoute.of(widget.context).settings.arguments;
    password = args?.password;
    _initScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              if (isLogin.hasData && isLogin.data) {
                return StreamBuilder<bool>(
                    initialData: authBloc.isPinShow,
                    stream: authBloc.outShowPin,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> outShowPin) {
                      return SharedPreferencesBuilder<dynamic>(
                        pref: 'switch_pin',
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> switchPinData) {
                          if (outShowPin.hasData && outShowPin.data) {
                            if (switchPinData.hasData && switchPinData.data) {
                              return Stack(
                                children: <Widget>[
                                  FutureBuilder<bool>(
                                    future: checkBiometrics(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<dynamic> snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data &&
                                          widget.pinStatus ==
                                              PinStatus.NORMAL_PIN) {
                                        Log.println('', snapshot.data);
                                        if (isLogin.hasData && isLogin.data) {
                                          authenticateBiometrics(
                                              context, widget.pinStatus);
                                        }
                                        return Container();
                                      }
                                      return Container();
                                    },
                                  ),
                                  PinPage(
                                    title:
                                        AppLocalizations.of(context).lockScreen,
                                    subTitle: AppLocalizations.of(context)
                                        .enterPinCode,
                                    pinStatus: widget.pinStatus,
                                    isFromChangingPin: false,
                                    onSuccess: widget.onSuccess,
                                  ),
                                ],
                              );
                            } else {
                              return SharedPreferencesBuilder<bool>(
                                  pref: 'switch_pin_biometric',
                                  builder: (BuildContext context,
                                      AsyncSnapshot<bool> switchPinBiometric) {
                                    if (switchPinBiometric.hasData &&
                                        switchPinBiometric.data) {
                                      return Stack(
                                        children: <Widget>[
                                          FutureBuilder<bool>(
                                            future: checkBiometrics(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<dynamic>
                                                    snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data &&
                                                  widget.pinStatus ==
                                                      PinStatus.NORMAL_PIN) {
                                                Log.println('', snapshot.data);
                                                if (isLogin.hasData &&
                                                    isLogin.data) {
                                                  authenticateBiometrics(
                                                      context,
                                                      widget.pinStatus);
                                                }
                                                return Container();
                                              }
                                              return Container();
                                            },
                                          ),
                                          BiometricPage(
                                            pinStatus: widget.pinStatus,
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Container();
                                    }
                                  });
                            }
                          } else {
                            if (widget.child == null &&
                                (widget.pinStatus == PinStatus.DISABLED_PIN ||
                                    widget.pinStatus ==
                                        PinStatus.DISABLED_PIN_BIOMETRIC))
                              return PinPage(
                                title: AppLocalizations.of(context).lockScreen,
                                subTitle:
                                    AppLocalizations.of(context).enterPinCode,
                                pinStatus: widget.pinStatus,
                                isFromChangingPin: false,
                              );
                            else
                              return widget.child;
                          }
                        },
                      );
                    });
              } else {
                return AuthenticatePage();
              }
            } else {
              return PinPage(
                title: AppLocalizations.of(context).createPin,
                subTitle: AppLocalizations.of(context).enterPinCode,
                firstCreationPin: true,
                pinStatus: PinStatus.CREATE_PIN,
                password: password,
                isFromChangingPin: false,
              );
            }
          },
        );
      },
    );
  }
}

class BiometricPage extends StatefulWidget {
  const BiometricPage({Key key, this.pinStatus}) : super(key: key);

  final PinStatus pinStatus;

  @override
  _BiometricPageState createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBarStatus(
        context: context,
        pinStatus: PinStatus.NORMAL_PIN,
        title: 'Fingerprint',
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.fingerprint,
                size: 56,
              ),
              const SizedBox(
                height: 16,
              ),
              RaisedButton(
                child: Text(
                    AppLocalizations.of(context).authenticate.toUpperCase()),
                onPressed: () =>
                    authenticateBiometrics(context, widget.pinStatus),
              )
            ],
          ),
        ),
      ),
    );
  }
}
