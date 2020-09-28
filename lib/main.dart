import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/drawer/drawer.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/rewards_provider.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/model/updates_provider.dart';
import 'package:komodo_dex/screens/feed/feed_page.dart';
import 'package:komodo_dex/screens/markets/markets_page.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/swap_page.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/services/music_service.dart';
import 'package:komodo_dex/services/notif_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:komodo_dex/widgets/buildRedDot.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import 'model/multi_order_provider.dart';
import 'model/startup_provider.dart';
import 'utils/utils.dart';
import 'widgets/shared_preferences_builder.dart';
import 'widgets/theme_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  applicationDocumentsDirectory; // Start getting the application directory.
  startApp();
}

Future<void> startApp() async {
  try {
    mmSe.metrics();
    startup.start();
    return runApp(_myAppWithProviders);
  } catch (e) {
    Log('main:46', 'startApp] $e');
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
            ),
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
          ],
          child: const MyApp(),
        ));

void _checkNetworkStatus() {
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    Log('main:71', 'ConnectivityResult: $result');
    if (result == ConnectivityResult.none) {
      mainBloc.setIsNetworkOffline(true);
    } else {
      if (!mmSe.running) startup.startMmIfUnlocked();
      if (mainBloc.isNetworkOffline) mainBloc.setIsNetworkOffline(false);
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({this.password});

  final String password;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        notifService.isInBackground = true;
        break;
      default:
        notifService.isInBackground = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.bottom,
      SystemUiOverlay.top,
    ]);
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final List<Widget> _children = <Widget>[
    CoinsPage(),
    SwapPage(),
    MarketsPage(),
    FeedPage(),
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
        Log('main:198', 'lifecycle: inactive');
        lockService.lockSignal(context);
        break;
      case AppLifecycleState.paused:
        Log('main:202', 'lifecycle: paused');
        lockService.lockSignal(context);

        // AG: do we really need it? // if (Platform.isIOS) mmSe.closeLogSink();

        // On iOS this corresponds to the ~5 seconds background mode before the app is suspended,
        // `applicationDidEnterBackground`, cf. https://github.com/flutter/flutter/issues/10123
        if (Platform.isIOS && await musicService.iosBackgroundExit()) {
          // https://gitlab.com/artemciy/supernet/issues/4#note_284468673
          Log('main:211', 'Suspended, exit');
          exit(0);
        }
        break;
      case AppLifecycleState.resumed:
        Log('main:216', 'lifecycle: resumed');
        lockService.lockSignal(context);
        if (Platform.isIOS) {
          if (!mmSe.running) await startup.startMmIfUnlocked();
        }
        break;
      case AppLifecycleState.detached:
        Log('main:223', 'lifecycle: detached');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FeedProvider feedProvider = Provider.of<FeedProvider>(context);
    final UpdatesProvider updatesProvider =
        Provider.of<UpdatesProvider>(context);

    notifService.init(AppLocalizations.of(context));

    return StreamBuilder<int>(
        initialData: mainBloc.currentIndexTab,
        stream: mainBloc.outCurrentIndex,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          return Scaffold(
            key: _scaffoldKey,
            endDrawer: AppDrawer(),
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
                                            key:
                                                const Key('main-nav-portfolio'),
                                          ),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .portfolio)),
                                      BottomNavigationBarItem(
                                          icon: Icon(Icons.swap_vert,
                                              key: const Key('main-nav-dex')),
                                          title: Text(
                                              AppLocalizations.of(context)
                                                  .dex)),
                                      BottomNavigationBarItem(
                                        icon: Icon(
                                          Icons.show_chart,
                                          key: const Key('main-nav-markets'),
                                        ),
                                        title: const Text(
                                            'Markets'), // TODO(yurii): localization
                                      ),
                                      BottomNavigationBarItem(
                                          icon: Stack(
                                            children: <Widget>[
                                              Icon(Icons.library_books,
                                                  key: const Key(
                                                      'main-nav-feed')),
                                              if (feedProvider.hasNewItems)
                                                buildRedDot(context),
                                            ],
                                          ),
                                          title: const Text('Feed')),
                                      BottomNavigationBarItem(
                                          icon: Stack(
                                            children: <Widget>[
                                              Icon(Icons.dehaze,
                                                  key: const Key(
                                                      'main-nav-more')),
                                              if (updatesProvider.status !=
                                                  UpdateStatus.upToDate)
                                                buildRedDot(context),
                                            ],
                                          ),
                                          title: const Text('More')),
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
    if (index < _children.length) {
      mainBloc.setCurrentIndexTab(index);
    } else {
      _scaffoldKey.currentState.openEndDrawer();
    }
  }
}
