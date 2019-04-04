import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/coin_json_bloc.dart';
import 'package:komodo_dex/blocs/orderbook_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authenticate_page.dart';
import 'package:komodo_dex/screens/bloc_coins_page.dart';
import 'package:komodo_dex/screens/pin_page.dart';
import 'package:komodo_dex/screens/setting_page.dart';
import 'package:komodo_dex/screens/swap_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    _checkPassphrase().then((data) {
      _runBinMm2UserAlreadyLog();
      runApp(BlocProvider(bloc: AuthenticateBloc(), child: MyApp()));
    });
  });
}

Future<void> _checkPassphrase() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getString("passphrase") != null &&
      prefs.getString("passphrase") != "") {
    prefs.setBool("switch_pin", true);
    authBloc.login(prefs.getString("passphrase"));
  }
}

_runBinMm2UserAlreadyLog() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('passphrase') != null &&
      prefs.getString('passphrase') != "") {
    await mm2.runBin();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'atomicDEX',
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [Locale("en")],
        theme: ThemeData(
          primaryColor: Color.fromRGBO(42, 54, 71, 1),
          backgroundColor: Color.fromRGBO(30, 42, 58, 1),
          primaryColorDark: Color.fromRGBO(42, 54, 71, 1),
          accentColor: Color.fromRGBO(65, 234, 213, 1),
          textSelectionColor: Colors.white,
          dialogBackgroundColor: Color.fromRGBO(42, 54, 71, 1),
          fontFamily: 'Ubuntu',
          hintColor: Colors.white,
          disabledColor: Color.fromRGBO(201, 201, 201, 1),
          buttonColor: Color.fromRGBO(39, 68, 108, 1),
          textTheme: TextTheme(
              headline: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
              title: TextStyle(
                  fontSize: 26.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
              subtitle: TextStyle(fontSize: 18.0, color: Colors.white),
              body1: TextStyle(fontSize: 16.0, color: Colors.white),
              button: TextStyle(fontSize: 16.0, color: Colors.white),
              body2: TextStyle(
                  fontSize: 14.0, color: Colors.white.withOpacity(0.5)),
              caption: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400)),
        ),
        home: StreamBuilder<bool>(
          stream: authBloc.outIsLogin,
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
                                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                                        if (snapshot.hasData && snapshot.data) {
                                          print(snapshot.data);
                                          _authenticateBiometrics();
                                        }
                                        return Container();
                                    },
                                    ),
                                    PinPage(
                                        title: 'Lock Screen',
                                        subTitle: 'Enter your PIN code',
                                        isConfirmPin: PinStatus.NORMAL_PIN),
                                  ],
                                );
                              } else {
                                return InitBlocs(child: MyHomePage());
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
                      isConfirmPin: PinStatus.CREATE_PIN);
                }
              },
            );
          },
        ));
  }

  Future<bool> _authenticateBiometrics() async{
    var localAuth = LocalAuthentication();
    
    bool didAuthenticate =
    await localAuth.authenticateWithBiometrics(
      
        localizedReason: 'Please authenticate to show account balance');
    if (didAuthenticate) {
      authBloc.showPin(false);
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

class InitBlocs extends StatefulWidget {
  final Widget child;

  InitBlocs({this.child});

  @override
  _InitBlocsState createState() => _InitBlocsState();
}

class _InitBlocsState extends State<InitBlocs> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderbookBloc>(
        bloc: OrderbookBloc(),
        child: BlocProvider<CoinJsonBloc>(
          bloc: CoinJsonBloc(),
          child: widget.child,
        ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final List<Widget> _children = [BlocCoinsPage(), SwapPage(), SettingPage()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print("inactive");
        break;
      case AppLifecycleState.paused:
        print("paused");
        authBloc.showPin(true);
        break;
      case AppLifecycleState.resumed:
        print("resumed");
        break;
      case AppLifecycleState.suspending:
        print("suspending");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: _children[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10.0, // has the effect of softening the shadow
              spreadRadius: 5.0, // has the effect of extending the shadow
              offset: Offset(
                10.0, // horizontal, move right 10
                10.0, // vertical, move down 10
              ),
            )
          ],
        ),
        child: Material(
          elevation: 8.0,
          child: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Theme.of(context).primaryColor,
                primaryColor: Theme.of(context).accentColor,
                textTheme: Theme.of(context).textTheme.copyWith(
                    caption: new TextStyle(
                        color: Theme.of(context)
                            .textSelectionColor
                            .withOpacity(0.5)))),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: onTabTapped,
              currentIndex: _currentIndex,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet),
                    title: Text("Portfolio")),
                BottomNavigationBarItem(
                    icon: Icon(Icons.swap_vert), title: Text("DEX")),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), title: Text("Settings")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
