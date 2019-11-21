import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/swap_page.dart';
import 'package:komodo_dex/screens/news/media_page.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/mode.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import 'blocs/coins_bloc.dart';
import 'widgets/shared_preferences_builder.dart';
import 'widgets/theme_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (isInDebugMode) {
    return runApp(BlocProvider<AuthenticateBloc>(
        bloc: AuthenticateBloc(), child: const MyApp()));
  } else {
    startApp();
  }
}

Future<void> startApp() async {
  try {
    await MarketMakerService().initMarketMaker();
    await _runBinMm2UserAlreadyLog();
    return runApp(BlocProvider<AuthenticateBloc>(
        bloc: AuthenticateBloc(), child: const MyApp()));
  } catch (e) {
    Log.println('', 'startApp] $e');
    rethrow;
  }
}

Future<void> _runBinMm2UserAlreadyLog() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('isPassphraseIsSaved') != null &&
      prefs.getBool('isPassphraseIsSaved') == true) {
    Log.println('', 'readJsonCoin');
    await coinsBloc.writeJsonCoin(await coinsBloc.readJsonCoin());
    await authBloc.initSwitchPref();

    if (!(authBloc.isPinShow && prefs.getBool('switch_pin'))) {
      Log.println('', 'login isPinShow');
      await authBloc.login(await EncryptionTool().read('passphrase'), null);
    }
  } else {
    Log.println('', 'loadJsonCoinsDefault');
    await coinsBloc
        .writeJsonCoin(await MarketMakerService().loadJsonCoinsDefault());
  }
}

void _checkNetworkStatus() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    print(result);
    if (result == ConnectivityResult.none) {
      mainBloc.setIsNetworkOffline(true);
    } else {
      if (mainBloc.isNetworkOffline) {
        if (!MarketMakerService().ismm2Running) {
          _runBinMm2UserAlreadyLog();
        }
        mainBloc.setIsNetworkOffline(false);
      }
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({this.password});

  final String password;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
    if (isInDebugMode) {
      MarketMakerService()
          .initMarketMaker()
          .then((_) => _runBinMm2UserAlreadyLog());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Locale>(
        stream: mainBloc.outcurrentLocale,
        builder: (BuildContext context, AsyncSnapshot<dynamic> currentLocale) {
          return SharedPreferencesBuilder<dynamic>(
              pref: 'current_languages',
              builder:
                  (BuildContext context, AsyncSnapshot<dynamic> prefLocale) {
                // Log.println('l10n - main.dart:118',
                //     'current locale: ' + currentLocale?.toString());
                // Log.println('l10n - main.dart:120',
                //     'current pref locale: ' + prefLocale.toString());

                return MaterialApp(
                    title: 'atomicDEX',
                    localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                      const AppLocalizationsDelegate(),
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate
                    ],
                    locale: currentLocale.hasData
                        ? currentLocale.data
                        : prefLocale.hasData ? Locale(prefLocale.data) : null,
                    supportedLocales: mainBloc.supportedLocales,
                    theme: getTheme(),
                    initialRoute: '/',
                    routes: <String, Widget Function(BuildContext)>{
                      // When we navigate to the '/' route, build the FirstScreen Widget
                      '/': (BuildContext context) => LockScreen(
                            context: context,
                            child: MyHomePage(),
                          ),
                    });
              });
        });
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Timer timer;

  final List<Widget> _children = <Widget>[
    CoinsPage(),
    SwapPage(),
    Media(),
    SettingPage()
  ];

  Future<void> _initLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('current_languages') == null) {
      final Locale loc = Localizations.localeOf(context);
      prefs.setString('current_languages', loc.languageCode);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initLanguage();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        // “your app is no longer responding to touch but is still foreground
        // (received a phone call, doing touch ID, et cetera)”
        Log.println('', 'inactive');
        break;
      case AppLifecycleState.paused:
        // On iOS this corresponds to the ~5 seconds background mode before the app is suspended,
        // `applicationDidEnterBackground`, cf. https://github.com/flutter/flutter/issues/10123
        if (Platform.isIOS) {
          final double btr = await MarketMakerService.platformmm2
              .invokeMethod('backgroundTimeRemaining');
          Log.println('', 'paused, backgroundTimeRemaining: $btr');
          // When `MusicService` is playing the music the `backgroundTimeRemaining` is large
          // and when we are silent the `backgroundTimeRemaining` is low
          // (expected low values are ~5, ~180, ~600 seconds).
          if (btr < 3600) {
            MarketMakerService().closeLogSink();
            if (!authBloc.isQrCodeActive && !mainBloc.isUrlLaucherIsOpen) {
              // https://gitlab.com/artemciy/supernet/issues/4#note_190147428
              Log.println('',
                  'Suspended, exiting explicitly in order to workaround a crash');
              exit(0);
            }
          }
        }
        dialogBloc.closeDialog(context);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('switch_pin_log_out_on_exit')) {
          authBloc.logout();
        }
        if (!authBloc.isQrCodeActive) {
          authBloc.showPin(true);
        }
        break;
      case AppLifecycleState.resumed:
        Log.println('', 'resumed');
        MarketMakerService().openLogSink();
        if (Platform.isIOS) {
          if (!MarketMakerService().ismm2Running) {
            _runBinMm2UserAlreadyLog();
          }
        }
        break;
      case AppLifecycleState.suspending:
        Log.println('', 'suspending');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        initialData: mainBloc.currentIndexTab,
        stream: mainBloc.outCurrentIndex,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: Theme.of(context).backgroundColor,
            body: _children[snapshot.data],
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                boxShadow: <BoxShadow>[
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
                          caption:
                              TextStyle(color: Colors.white.withOpacity(0.5)))),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: SafeArea(
                      child: StreamBuilder<bool>(
                          initialData: mainBloc.isNetworkOffline,
                          stream: mainBloc.outIsNetworkOffline,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> netWork) {
                            final bool isNetworkAvailable = netWork.data;
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
                                    items: <BottomNavigationBarItem>[
                                      BottomNavigationBarItem(
                                          icon: Icon(
                                            Icons.account_balance_wallet,
                                            key: const Key(
                                                'icon-bloc-coins-page'),
                                          ),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .portfolio)),
                                      BottomNavigationBarItem(
                                          icon: Icon(Icons.swap_vert,
                                              key: const Key('icon-swap-page')),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .dex)),
                                      BottomNavigationBarItem(
                                          icon: Icon(Icons.library_books,
                                              key: const Key('icon-media')),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .media)),
                                      BottomNavigationBarItem(
                                          icon: Icon(Icons.settings,
                                              key: const Key(
                                                  'icon-setting-page')),
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
