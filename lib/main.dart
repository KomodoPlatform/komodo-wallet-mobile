import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/swap_page.dart';
import 'package:komodo_dex/screens/news/media_page.dart';
import 'package:komodo_dex/screens/portfolio/bloc_coins_page.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import 'blocs/coins_bloc.dart';

void main() async {
  bool isInDebugMode = false;

  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Crashlytics.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  await FlutterCrashlytics().initialize();

  runZoned<Future<Null>>(() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      _checkNetworkStatus();
      startApp();
    });
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Crashlytics depending on the environment.
    print(stackTrace);
    await FlutterCrashlytics()
        .reportCrash(error, stackTrace, forceCrash: false);
  });
}

startApp() {
  mm2.initMarketMaker().then((_) {
    _runBinMm2UserAlreadyLog().then((onValue) {
      runApp(BlocProvider(bloc: AuthenticateBloc(), child: MyApp()));
    });
  });
}

Future<void> _runBinMm2UserAlreadyLog() async {
  String passphrase = await new EncryptionTool().read("passphrase");
  if (passphrase != null && passphrase.isNotEmpty) {
    print("readJsonCoin");
    await coinsBloc.writeJsonCoin(await coinsBloc.readJsonCoin());
    await authBloc.initSwitchPref();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!(authBloc.isPinShow && prefs.getBool("switch_pin"))) {
      print("login isPinShow");
      await authBloc.login(await new EncryptionTool().read("passphrase"), null);
    }
  } else {
    print("loadJsonCoinsDefault");
    await coinsBloc.writeJsonCoin(await mm2.loadJsonCoinsDefault());
  }
}

_checkNetworkStatus() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      mainBloc.setIsNetworkOffline(true);
    } else {
      if (mainBloc.isNetworkOffline) {
        _runBinMm2UserAlreadyLog();
        mainBloc.setIsNetworkOffline(false);
      }
    }
  });
}

class MyApp extends StatefulWidget {
  final String password;

  MyApp({this.password});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "atomicDEX",
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [Locale("en")],
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color.fromRGBO(42, 54, 71, 1),
          backgroundColor: Color.fromRGBO(30, 42, 58, 1),
          primaryColorDark: Color.fromRGBO(42, 54, 71, 1),
          accentColor: Color.fromRGBO(65, 234, 213, 1),
          textSelectionColor: Color.fromRGBO(65, 234, 213, 1).withOpacity(0.3),
          dialogBackgroundColor: Color.fromRGBO(42, 54, 71, 1),
          fontFamily: 'Ubuntu',
          hintColor: Colors.white,
          errorColor: Color.fromRGBO(220, 3, 51, 1),
          disabledColor: Color.fromRGBO(201, 201, 201, 1),
          buttonColor: Color.fromRGBO(39, 68, 108, 1),
          cursorColor: Color.fromRGBO(65, 234, 213, 1),
          textSelectionHandleColor: Color.fromRGBO(65, 234, 213, 1),
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
              body1: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
              button: TextStyle(fontSize: 16.0, color: Colors.white),
              body2: TextStyle(
                  fontSize: 14.0, color: Colors.white.withOpacity(0.5)),
              caption: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400)),
        ),
        initialRoute: '/',
        routes: {
          // When we navigate to the "/" route, build the FirstScreen Widget
          '/': (context) => LockScreen(
                child: MyHomePage(),
              ),
        });
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  var timer;

  final List<Widget> _children = [
    BlocCoinsPage(),
    SwapPage(),
    Media(),
    SettingPage()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        print("inactive");
        break;
      case AppLifecycleState.paused:
        print("paused");
        dialogBloc.closeDialog(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.getBool("switch_pin_log_out_on_exit")) {
          authBloc.logout();
        }
        if (!authBloc.isQrCodeActive) authBloc.showPin(true);
        break;
      case AppLifecycleState.resumed:
        print("resumed");
        break;
      case AppLifecycleState.suspending:
        print("suspending");
        await mm2.stopmm2();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        initialData: mainBloc.currentIndexTab,
        stream: mainBloc.outCurrentIndex,
        builder: (context, snapshot) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: Theme.of(context).backgroundColor,
            body: _children[snapshot.data],
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
                              color: Colors.white.withOpacity(0.5)))),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: SafeArea(
                      child: StreamBuilder<bool>(
                          initialData: mainBloc.isNetworkOffline,
                          stream: mainBloc.outIsNetworkOffline,
                          builder: (context, netWork) {
                            bool isNetworkAvailable = netWork.data;
                            return SizedBox(
                              height: isNetworkAvailable ? 80 : 56,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  if (isNetworkAvailable)
                                    Expanded(
                                      child: Center(
                                        child: Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            color: Colors.redAccent,
                                            child: Center(
                                                child: Text(
                                                    AppLocalizations.of(context)
                                                        .noInternet))),
                                      ),
                                    ),
                                  BottomNavigationBar(
                                    elevation: 0,
                                    type: BottomNavigationBarType.fixed,
                                    onTap: onTabTapped,
                                    currentIndex: snapshot.data,
                                    items: [
                                      BottomNavigationBarItem(
                                          icon: Icon(
                                              Icons.account_balance_wallet),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .portfolio)),
                                      BottomNavigationBarItem(
                                          icon: Icon(Icons.swap_vert),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .dex)),
                                      BottomNavigationBarItem(
                                          icon: Icon(Icons.library_books),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .media)),
                                      BottomNavigationBarItem(
                                          icon: Icon(Icons.settings),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .settings)),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void onTabTapped(int index) {
    mainBloc.setCurrentIndexTab(index);
  }
}
