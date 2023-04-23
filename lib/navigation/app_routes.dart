import 'package:komodo_dex/packages/portfolio/navigation/location.dart';
import 'package:komodo_dex/packages/portfolio/navigation/routes.dart';
import 'package:komodo_dex/packages/wallet_profiles/navigation/routes.dart';

/// An index of all routes in the app. When adding a new route file to the app,
/// add it to this file.
class AppRoutes {
  AppRoutes._();

  static WalletRoutes get wallet => WalletRoutes();

  static PortfolioRoutes get portfolio => PortfolioRoutes();
}
