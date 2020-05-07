import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/markets/markets_page.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/swap_page.dart';
import 'package:komodo_dex/screens/news/media_page.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/services/music_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import 'utils/utils.dart';
import 'widgets/shared_preferences_builder.dart';
import 'widgets/theme_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  applicationDocumentsDirectory; // Start getting the application directory.
  if (isInDebugMode) {
    return runApp(_myAppWithProviders);
  } else {
    startApp();
  }
}

Future<void> startApp() async {
  try {
    mmSe.metrics();
    await mmSe.updateMmBinary();
    await _runBinMm2UserAlreadyLog();
    return runApp(_myAppWithProviders);
  } catch (e) {
    Log('main:51', 'startApp] $e');
    rethrow;
  }
}

BlocProvider<AuthenticateBloc> _myAppWithProviders =
    BlocProvider<AuthenticateBloc>(
        bloc: AuthenticateBloc(),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => SwapProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => OrderBookProvider(),
            )
          ],
          child: const MyApp(),
        ));

Future<void> _runBinMm2UserAlreadyLog() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('isPassphraseIsSaved') != null &&
      prefs.getBool('isPassphraseIsSaved') == true) {
    await authBloc.initSwitchPref();

    if (!(authBloc.showLock && prefs.getBool('switch_pin'))) {
      await authBloc.login(await EncryptionTool().read('passphrase'), null);
    }
  }
}

void _checkNetworkStatus() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    print(result);
    if (result == ConnectivityResult.none) {
      mainBloc.setIsNetworkOffline(true);
    } else {
      if (mainBloc.isNetworkOffline) {
        if (!mmSe.running) {
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
      mmSe.updateMmBinary().then((_) => _runBinMm2UserAlreadyLog());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: getTheme().backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Forward pointer events to LockService.
    return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => lockService.pointerEvent(context),
        onPointerUp: (_) => lockService.pointerEvent(context),
        child: StreamBuilder<Locale>(
            stream: mainBloc.outcurrentLocale,
            builder:
                (BuildContext context, AsyncSnapshot<dynamic> currentLocale) {
              return SharedPreferencesBuilder<dynamic>(
                  pref: 'current_languages',
                  builder: (BuildContext context,
                      AsyncSnapshot<dynamic> prefLocale) {
                    // Log('main:140',
                    //     'current locale: ' + currentLocale?.toString());
                    // Log('main:142',
                    //     'current pref locale: ' + prefLocale.toString());

                    return MaterialApp(
                        title: 'atomicDEX',
                        localizationsDelegates: <
                            LocalizationsDelegate<dynamic>>[
                          const AppLocalizationsDelegate(),
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate
                        ],
                        locale: currentLocale.hasData
                            ? currentLocale.data
                            : prefLocale.hasData
                                ? Locale(prefLocale.data)
                                : null,
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
            }));
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
    MarketsPage(),
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
    lockService.initialize();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // https://developer.apple.com/documentation/uikit/app_and_environment/managing_your_app_s_life_cycle
    switch (state) {
      case AppLifecycleState.inactive:
        // willResignActive: “your app is no longer responding to touch but is still foreground
        // (received a phone call, doing touch ID, et cetera)”
        // - https://github.com/flutter/flutter/issues/10123#issuecomment-302763382
        // Picking a file also triggers this on Android (?), as it switches into a system activity.
        // On iOS *after* picking a file the app returns to `inactive`,
        // on Android to `inactive` and then `resumed`.
        Log('main:224', 'lifecycle: inactive');
        lockService.lockSignal(context);
        break;
      case AppLifecycleState.paused:
        Log('main:228', 'lifecycle: paused');
        lockService.lockSignal(context);

        // AG: do we really need it? // if (Platform.isIOS) mmSe.closeLogSink();

        // On iOS this corresponds to the ~5 seconds background mode before the app is suspended,
        // `applicationDidEnterBackground`, cf. https://github.com/flutter/flutter/issues/10123
        if (Platform.isIOS && await musicService.iosBackgroundExit()) {
          // https://gitlab.com/artemciy/supernet/issues/4#note_284468673
          Log('main:237', 'Suspended, exit');
          exit(0);
        }
        break;
      case AppLifecycleState.resumed:
        Log('main:242', 'lifecycle: resumed');
        lockService.lockSignal(context);
        if (Platform.isIOS) {
          if (!mmSe.running) {
            _runBinMm2UserAlreadyLog();
          }
        }
        break;
      case AppLifecycleState.detached:
        Log('main:251', 'lifecycle: detached');
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
                                        icon: Icon(
                                          Icons.show_chart,
                                          key: const Key('icon-markets-page'),
                                        ),
                                        title: const Text(
                                            'Markets'), // TODO(yurii): localization
                                      ),
                                      BottomNavigationBarItem(
                                          icon: Icon(Icons.library_books,
                                              key: const Key('icon-media')),
                                          title: const Text(
                                              'Feed')), // TODO(yurii): localization
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
