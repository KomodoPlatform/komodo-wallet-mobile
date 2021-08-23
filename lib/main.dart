import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/drawer/drawer.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/model/intent_data_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/rewards_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/model/updates_provider.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/dex_page.dart';
import 'package:komodo_dex/screens/feed/feed_page.dart';
import 'package:komodo_dex/screens/markets/markets_page.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/coin_detail.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:komodo_dex/widgets/buildRedDot.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_config/theme_data.dart';
import 'model/multi_order_provider.dart';
import 'model/startup_provider.dart';
import 'utils/utils.dart';
import 'widgets/shared_preferences_builder.dart';

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
            ChangeNotifierProvider(
              create: (context) => IntentDataProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => ConstructorProvider(),
            ),
          ],
          child: const MyApp(),
        ));

void _initCheckNetworkStatus() {
  Connectivity().onConnectivityChanged.listen(_checkNetworkStatus);
}

Future<void> _checkNetworkStatus(ConnectivityResult result) async {
  Log('main:101', 'ConnectivityResult: $result');
  if (result == ConnectivityResult.none) {
    mainBloc.setNetworkStatus(NetworkStatus.Offline);
  } else {
    if (!mmSe.running) startup.startMmIfUnlocked();
    if (mainBloc.networkStatus == NetworkStatus.Offline ||
        mainBloc.networkStatus == NetworkStatus.Checking) {
      mainBloc.setNetworkStatus(NetworkStatus.Restored);
      await Future.delayed(Duration(seconds: 2), () {});
      mainBloc.setNetworkStatus(NetworkStatus.Online);
    }
  }
}

Future<void> _forceCheckNetworkStatus() async {
  mainBloc.setNetworkStatus(NetworkStatus.Checking);
  await Future.delayed(Duration(seconds: 2), () {});
  final connectivity = await Connectivity().checkConnectivity();
  await _checkNetworkStatus(connectivity);
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
    _initCheckNetworkStatus();
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
        mainBloc.isInBackground = true;
        Log('main', 'lifecycle: inactive');
        lockService.lockSignal(context);
        break;
      case AppLifecycleState.paused:
        Log('main', 'lifecycle: paused');
        mainBloc.isInBackground = true;
        lockService.lockSignal(context);
        break;
      case AppLifecycleState.detached:
        Log('main', 'lifecycle: detached');
        mainBloc.isInBackground = true;
        break;
      case AppLifecycleState.resumed:
        Log('main', 'lifecycle: resumed');
        mainBloc.isInBackground = false;
        lockService.lockSignal(context);
        await mmSe.handleWakeUp();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.bottom,
      SystemUiOverlay.top,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: getThemeDark().backgroundColor,
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
                    return StreamBuilder<bool>(
                      stream: settingsBloc.outLightTheme,
                      initialData: settingsBloc.isLightTheme,
                      builder: (BuildContext cont,
                          AsyncSnapshot<dynamic> currentTheme) {
                        return MaterialApp(
                            title: appConfig.appName,
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
                            theme: settingsBloc.isLightTheme
                                ? getThemeLight()
                                : getThemeDark(),
                            initialRoute: '/',
                            routes: <String, Widget Function(BuildContext)>{
                              // When we navigate to the '/' route, build the FirstScreen Widget
                              '/': (BuildContext context) => LockScreen(
                                    context: context,
                                    child: MyHomePage(),
                                  ),
                            });
                      },
                    );
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
  IntentDataProvider _intentDataProvider;

  final List<Widget> _children = <Widget>[
    CoinsPage(),
    DexPage(),
    MarketsPage(),
    FeedPage(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _intentDataProvider?.grabData();
      pinScreenOrientation(context);
    });

    _initLanguage();
    lockService.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _intentDataProvider?.grabData();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    _intentDataProvider ??= Provider.of<IntentDataProvider>(context);
    final FeedProvider feedProvider = Provider.of<FeedProvider>(context);
    final UpdatesProvider updatesProvider =
        Provider.of<UpdatesProvider>(context);

    _handleIntentData(_scaffoldKey);

    return StreamBuilder<int>(
      initialData: mainBloc.currentIndexTab,
      stream: mainBloc.outCurrentIndex,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: AppDrawer(context),
          resizeToAvoidBottomPadding: true,
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
                    textTheme: Theme.of(context).textTheme),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: SafeArea(
                    child: networkStatusStreamBuilder(
                      snapshot,
                      feedProvider,
                      updatesProvider,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _initLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('current_languages') == null) {
      final Locale loc = Localizations.localeOf(context);
      prefs.setString('current_languages', loc.languageCode);
    }
  }

  void _emptyIntentData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _intentDataProvider.emptyIntentData();
    });
  }

  Future<void> _handleIntentData(GlobalKey<ScaffoldState> scaffoldKey) async {
    final data = _intentDataProvider.intentData;
    if (data == null) return;

    while (coinsBloc.coinBalance.isEmpty) {
      await Future<dynamic>.delayed(Duration(milliseconds: 100));
    }

    CoinBalance coinBalance;
    if (data.screen == ScreenSelection.Ethereum) {
      coinBalance = coinsBloc.coinBalance
          .firstWhere((cb) => cb.coin.abbr == 'ETH', orElse: () => null);
    } else if (data.screen == ScreenSelection.Bitcoin) {
      coinBalance = coinsBloc.coinBalance
          .firstWhere((cb) => cb.coin.abbr == 'BTC', orElse: () => null);
    } else {
      _emptyIntentData();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Uri uri = Uri.tryParse(data.payload);

      if (uri == null) return;

      final PaymentUriInfo uriInfo = PaymentUriInfo.fromUri(uri);

      if (uriInfo == null) return;

      showUriDetailsDialog(
        context,
        uriInfo,
        () {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (context) => CoinDetail(
                coinBalance: coinBalance,
                isSendIsActive: true,
                paymentUriInfo: uriInfo,
              ),
            ),
          );
        },
      );

      _emptyIntentData();
    });
  }

  Widget networkStatusStreamBuilder(AsyncSnapshot<int> snapshot,
      FeedProvider feedProvider, UpdatesProvider updatesProvider) {
    return StreamBuilder<NetworkStatus>(
      initialData: mainBloc.networkStatus,
      stream: mainBloc.outNetworkStatus,
      builder: (BuildContext context, AsyncSnapshot<NetworkStatus> network) {
        final NetworkStatus networkStatus = network.data;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (networkStatus != NetworkStatus.Online)
              Material(
                color: networkStatus == NetworkStatus.Restored
                    ? Colors.greenAccent
                    : Colors.redAccent,
                child: Container(
                  child: networkStatus == NetworkStatus.Restored
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context).internetRestored,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).noInternet,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(child: SizedBox()),
                              InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      if (networkStatus ==
                                          NetworkStatus.Checking)
                                        SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                      if (networkStatus ==
                                          NetworkStatus.Checking)
                                        SizedBox(width: 8),
                                      Text(
                                        AppLocalizations.of(context)
                                            .internetRefreshButton,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: networkStatus == NetworkStatus.Checking
                                    ? null
                                    : () {
                                        _forceCheckNetworkStatus();
                                      },
                              ),
                            ],
                          ),
                        ),
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
                      key: const Key('main-nav-portfolio'),
                    ),
                    label: AppLocalizations.of(context).portfolio),
                BottomNavigationBarItem(
                    icon: Icon(Icons.swap_vert, key: const Key('main-nav-dex')),
                    label: AppLocalizations.of(context).dex),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.show_chart,
                    key: const Key('main-nav-markets'),
                  ),
                  label: AppLocalizations.of(context).marketsTab,
                ),
                BottomNavigationBarItem(
                    icon: Stack(
                      children: <Widget>[
                        Icon(Icons.library_books,
                            key: const Key('main-nav-feed')),
                        if (feedProvider.hasNewItems) buildRedDot(context),
                      ],
                    ),
                    label: AppLocalizations.of(context).feedTab),
                BottomNavigationBarItem(
                    icon: Stack(
                      children: <Widget>[
                        Icon(Icons.dehaze, key: const Key('main-nav-more')),
                        if (updatesProvider.status != UpdateStatus.upToDate)
                          buildRedDot(context),
                      ],
                    ),
                    label: AppLocalizations.of(context).moreTab),
              ],
            )
          ],
        );
      },
    );
  }

  void onTabTapped(int index) {
    if (index < _children.length) {
      mainBloc.setCurrentIndexTab(index);
    } else {
      _scaffoldKey.currentState.openEndDrawer();
    }
  }
}
