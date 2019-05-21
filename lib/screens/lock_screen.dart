import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authenticate_page.dart';
import 'package:komodo_dex/screens/confirm_account_page.dart';
import 'package:komodo_dex/screens/pin_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockScreen extends StatefulWidget {
  final PinStatus pinStatus;
  final Widget child;

  LockScreen({this.pinStatus = PinStatus.NORMAL_PIN, this.child});

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: authBloc.outIsLogin,
      initialData: authBloc.isLogin,
      builder: (context, isLogin) {
        return StreamBuilder(
          initialData: authBloc.pinStatus,
          stream: authBloc.outpinStatus,
          builder: (context, outShowCreatePin) {
            if (outShowCreatePin.hasData &&
                (outShowCreatePin.data == PinStatus.NORMAL_PIN)) {
              if (isLogin.hasData && isLogin.data) {
                return StreamBuilder(
                    initialData: authBloc.isPinShow,
                    stream: authBloc.outShowPin,
                    builder: (context, outShowPin) {
                      return SharedPreferencesBuilder(
                        pref: 'switch_pin',
                        builder: (context, switchPinData) {
                          if (outShowPin.hasData &&
                              outShowPin.data &&
                              switchPinData.hasData &&
                              switchPinData.data) {
                            return Stack(
                              children: <Widget>[
                                FutureBuilder(
                                  future: _checkBiometrics(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData && snapshot.data) {
                                      print(snapshot.data);
                                      _authenticateBiometrics();
                                      return Container();
                                    }
                                    return Container();
                                  },
                                ),
                                PinPage(
                                  title:
                                      AppLocalizations.of(context).lockScreen,
                                  subTitle:
                                      AppLocalizations.of(context).enterPinCode,
                                  isConfirmPin: widget.pinStatus,
                                  isFromChangingPin: false,
                                ),
                              ],
                            );
                          } else {
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
                isConfirmPin: PinStatus.CREATE_PIN,
                isFromChangingPin: false,
              );
            }
          },
        );
      },
    );
  }

  Future<bool> _authenticateBiometrics() async {
    var localAuth = LocalAuthentication();

    bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: AppLocalizations.of(context).lockScreenAuth);
    if (didAuthenticate) {
      if (widget.pinStatus == PinStatus.DISABLED_PIN) {
        SharedPreferences.getInstance().then((data) {
          data.setBool("switch_pin", false);
        });
        Navigator.pop(context);
      }
      authBloc.showPin(false);
      if (widget.pinStatus == PinStatus.NORMAL_PIN && !mm2.ismm2Running) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await authBloc.login(prefs.getString("passphrase"));
      }
    }
    return didAuthenticate;
  }

  Future<bool> _checkBiometrics() async {
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      print(canCheckBiometrics);
    } on PlatformException catch (e) {
      print(e);
    }
    return canCheckBiometrics;
  }
}
