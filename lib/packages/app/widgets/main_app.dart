import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:komodo_dex/generic_blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/navigation/app_locations.dart';
import 'package:komodo_dex/navigation/app_routes.dart';
import 'package:komodo_dex/packages/accounts/bloc/active_account_bloc.dart';
import 'package:komodo_dex/packages/app/widgets/middleware_widgets.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/auth_active_account_listener.dart';
import 'package:provider/provider.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  /// The [GlobalKey] for the [ScaffoldMessenger] widget so that we can show
  /// snackbars from anywhere in the app.
  ///
  /// NB! Don't use this in a bloc. This should only be used in the UI only.
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  // final LocalAuthentication auth = LocalAuthentication();
  //TODO: Create a navigation system which integrates with some/all of of these:
  //  - Authentication Bloc
  //  - Network Status Bloc

  // @override
  // void initState() {
  //   super.initState();
  //   _initCheckNetworkStatus();
  //   WidgetsBinding.instance.addObserver(this);
  // }
  @override
  void initState() {
    super.initState();
    setState(() {
      _appLocale = WidgetsBinding.instance.platformDispatcher.locale;
    });
  }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  // TODO: Move locale handling to a new bloc?

  /// The locale used by the app. If
  Locale? _appLocale;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: Use below to handle app lifecycle changes in a auth/lock bloc
    switch (state) {
      case AppLifecycleState.inactive:
        mainBloc.isInBackground = true;
        Log('main', 'lifecycle: inactive');
        // lockService.lockSignal(context);
        break;
      case AppLifecycleState.paused:
        Log('main', 'lifecycle: paused');
        mainBloc.isInBackground = true;
        // lockService.lockSignal(context);
        break;
      case AppLifecycleState.detached:
        Log('main', 'lifecycle: detached');
        mainBloc.isInBackground = true;
        break;
      case AppLifecycleState.resumed:
        Log('main', 'lifecycle: resumed');
        mainBloc.isInBackground = false;
        // lockService.lockSignal(context);
        // TODO: Replace with new mmservice manager
        await mmSe.handleWakeUp();
        break;
    }
  }

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: [
      SystemUiOverlay.bottom,
      SystemUiOverlay.top,
    ]);

    final systemUIBrightness = Theme.of(context).brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: systemUIBrightness,
      statusBarBrightness: systemUIBrightness,
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ));

    final maybeUserThemeColor = context.select<ActiveAccountBloc, Color?>(
        (bloc) => bloc.state.activeAccount?.themeColor);

    final appTheme = systemUIBrightness == Brightness.dark
        // To be implemented soon. See branch: feature/m3-dynamic-theme
        ? getThemeDark(/*seed: maybeUserThemeColor*/)
        : getThemeLight(/*seed: maybeUserThemeColor*/);

    return BeamerProvider(
      routerDelegate: routerDelegate,
      key: _beamerKey,
      child: AuthActiveAccountListener(
        key: Key('main_app_auth_active_account_listener'),
        child: MaterialApp.router(
            key: Key('main_app_material_app'),
            scaffoldMessengerKey: MainApp.rootScaffoldMessengerKey,
            title: appConfig.appName,
            localizationsDelegates: localizationsDelegates,
            theme: appTheme,
            builder: (context, child) =>
                MiddlewareWidgets(child: child ?? Container()),
            // themeMode: ThemeMode.dark,
            routerDelegate: routerDelegate,
            routeInformationParser: _routeInformationParser
            // TODO: Transition legacy routes/pages to new navigation system which
            // takes advantage of Navigator 2.0 .
            // Even though we don't use URL based navigation on mobile, it's still
            // a good way to keep things organized and it allows us to do some cool
            // things like deep linking.
            ),
      ),
    );
  }

  final GlobalKey<BeamerState> _beamerKey = GlobalKey<BeamerState>();

  final BeamerParser _routeInformationParser = BeamerParser(onParse: (info) {
    return info;
  });

  final routerDelegate = BeamerDelegate(
    initialPath: AppRoutes.wallet.login(),
    locationBuilder: BeamerLocationBuilder(
      beamLocations: appLocations,
    ),
    notFoundPage: BeamPage(
      key: const ValueKey('not_found'),
      child: Scaffold(
        body: Center(
          child: Text('Not Found.'),
        ),
      ),
    ),
  );
}
