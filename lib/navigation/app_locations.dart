// lib/navigation/app_locations.dart
import 'package:beamer/beamer.dart';
import 'package:komodo_dex/packages/portfolio/navigation/location.dart';
import 'package:komodo_dex/packages/wallet_profiles/navigation/locations.dart';

final List<BeamLocation> appLocations = [
  WalletProfilesLocation(),
  PortfolioLocation(),
];
