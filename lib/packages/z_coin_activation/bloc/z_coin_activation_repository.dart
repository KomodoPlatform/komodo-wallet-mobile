import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_api.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_status.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZCoinActivationRepository {
  ZCoinActivationRepository(this.api);

  final ZCoinActivationApi api;

  static Future<String> get taskIdKey async =>
      'activationTaskId_${(await Db.getCurrentWallet()).id}';

  static Future<String> _getRequestedActivationKey() async {
    final walletId = (await Db.getCurrentWallet()).id;

    return 'z-coin-activation-requested-$walletId';
  }

  /// Returns the list of ZCoins the user wants activated, regardless of whether
  /// they are already activated or not.
  Future<List<String>> requestedActivatedCoins() async {
    final prefs = await SharedPreferences.getInstance();

    final key = await _getRequestedActivationKey();

    final isRequested = prefs.getBool(key);

    if (isRequested == null || !isRequested) return [];

    final zCoinsToActivate = await getKnownZCoins();

    return zCoinsToActivate.map((c) => c.abbr).toList();
  }

  Future<bool> hasOutstandingActivationRequest() async {
    final prefs = await SharedPreferences.getInstance();

    final key = await _getRequestedActivationKey();

    final isRequested = prefs.getBool(key);

    return isRequested != null && isRequested;
  }

  Stream<ZCoinStatus> activateAllZCoins() async* {
    final zCoinsToActivate = await getNonEnabledZCoins();

    if (zCoinsToActivate.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(await _getRequestedActivationKey(), true);

    final hasAnyZCoinActivated = await isAnyZCoinActivated();

    while (zCoinsToActivate.isNotEmpty) {
      await for (final update in api.activateCoin(zCoinsToActivate.first)) {
        yield update;
      }
      zCoinsToActivate.removeAt(0);
    }

    await coinsBloc.syncCoinsStateWithApi(false);
  }

  Future<void> initiateOrResumeActivation(String abbr) async {
    final hasTaskInProgress = await hasOngoingActivation(abbr);

    if (hasTaskInProgress) {
      return;
    }

    return await api.initiateActivation(abbr);
  }

  Future<bool> hasOngoingActivation(String abbr) async {
    final taskId = await api.getTaskId(abbr);

    if (taskId == null) return false;

    final status = await api.activationTaskStatus(taskId, ticker: abbr);

    return status.isInProgress;
  }

  Future<bool> isAllZCoinsEnabled() async {
    final zCoinsToActivate = await getNonEnabledZCoins();

    return zCoinsToActivate.isEmpty;
  }

  Future<bool> isAnyZCoinActivated() async {
    final zCoinsToActivate = await getNonEnabledZCoins();

    return zCoinsToActivate.isNotEmpty;
  }

  Future<List<String>> getEnabledZCoins() async {
    return await api.activatedZCoins();
  }

  Future<List<String>> getNonEnabledZCoins() async {
    final activatedZCoins = await getEnabledZCoins();
    final knownZCoins = await getKnownZCoins();

    return knownZCoins
        .where((c) => !activatedZCoins.contains(c.abbr))
        .map((c) => c.abbr)
        .toList();
  }

  Future<List<Coin>> getKnownZCoins() async {
    return await api.getKnownZCoins();
  }

  Stream<ZCoinStatus> activationStatusStream() async* {
    final zCoinsToActivate = await getNonEnabledZCoins();

    // If there are no coins to activate, immediately return.
    if (zCoinsToActivate.isEmpty) return;

    while (zCoinsToActivate.isNotEmpty) {
      List<Future<ActivationTaskStatus>> futures =
          zCoinsToActivate.map((coin) async {
        final taskId = await api.getTaskId(coin);

        if (taskId == null) {
          return ActivationTaskStatus.notFound;
        }

        final status = await api.activationTaskStatus(taskId, ticker: coin);

        final isActivated =
            status != null && status.status == ActivationTaskStatus.active;

        // If the coin is activated, remove it from the list of coins to activate.
        if (isActivated) {
          zCoinsToActivate.remove(coin);
        }

        return status;
      }).toList();

      // Wait for all status checks to complete.
      final statuses = await Future.wait(futures);

      // Yield each status to the stream.
      for (final status in statuses) {
        yield ZCoinStatus.fromTaskStatus(zCoinsToActivate.first, status);
      }

      // If all coins are activated, break the loop to end the stream.
      if (zCoinsToActivate.isEmpty) break;

      // Otherwise, wait a while before checking the statuses again.
      await Future.delayed(Duration(seconds: 5));
    }

    await coinsBloc.syncCoinsStateWithApi(false);
  }

  Future<List<ZCoinStatus>> getActivationStatusOfAllCoins() async {
    final zCoinsToActivate = await getNonEnabledZCoins();
    final statuses = await Future.wait(zCoinsToActivate.map((coin) async {
      final taskId = await api.getTaskId(coin);
      if (taskId == null) {
        return ZCoinStatus.fromTaskStatus(coin, ActivationTaskStatus.notFound);
      }

      final status = await api.activationTaskStatus(taskId, ticker: coin);
      return status;
    }));

    return statuses;
  }
}
