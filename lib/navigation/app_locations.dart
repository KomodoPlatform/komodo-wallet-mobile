// lib/navigation/app_locations.dart
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/accounts/navigation/location.dart';
import 'package:komodo_dex/packages/portfolio/navigation/location.dart';
import 'package:komodo_dex/packages/wallets/navigation/locations.dart';
import 'package:komodo_dex/screens/dex/dex_page.dart';
import 'legacy_locations.dart';

final List<BeamLocation> appLocations = [
  WalletsLocation(),
  // PortfolioLocation(),
  AccountsManagementLocation(),
  LegacyAppBarLocations(),
];
