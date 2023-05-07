// lib/navigation/app_locations.dart
import 'package:beamer/beamer.dart';
import 'package:komodo_dex/packages/accounts/navigation/location.dart';
import 'package:komodo_dex/packages/portfolio/navigation/location.dart';
import 'package:komodo_dex/packages/wallets/navigation/locations.dart';

final List<BeamLocation> appLocations = [
  WalletsLocation(),
  PortfolioLocation(),
  AccountsManagementLocation(),
];
