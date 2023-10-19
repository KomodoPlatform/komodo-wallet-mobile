import 'dart:async';

import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_api.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_requested_activation_storage.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_status.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/log.dart';

class ZCoinActivationRepository with RequestedZCoinsStorage {
  ZCoinActivationRepository(this.api);

  final ZCoinActivationApi api;

  static Future<String> get taskIdKey async =>
      'activationTaskId_${(await Db.getCurrentWallet()).id}';

  Stream<ZCoinStatus> resyncZCoins() async* {
    final outStandingZCoins = await outstandingZCoinActivations();

    yield* _activateZCoins(outStandingZCoins, resyncOnly: true);
  }

  Stream<ZCoinStatus> _activateZCoins(
    List<String> zCoins, {
    bool resyncOnly = false,
  }) async* {
    try {
      if (zCoins.isEmpty) return;

      while (zCoins.isNotEmpty) {
        final currentCoinTicker = zCoins.first;
        await for (final update
            in api.activateCoin(currentCoinTicker, resync: resyncOnly)) {
          Log(
            'ZCoinActivationRepository:activateZCoins',
            'Update received: ${update.toJson()}',
          );
          if (update.isActivated) {
            final coin = (await coins)[currentCoinTicker];
            final isRegistered = coin?.isActive ?? false;

            if (!isRegistered) {
              await coinsBloc.setupCoinAfterActivation(coin);
            }
          } else if (update.status == ActivationTaskStatus.failed) {
            await removeRequestedActivatedCoins([currentCoinTicker]);
            await api.removeTaskId(currentCoinTicker);
            await coinsBloc.syncCoinsStateWithApi();
          }

          yield update;
        }
        if (zCoins.isNotEmpty) {
          zCoins.removeAt(0);
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      api.resetFirstScannedBlocks();
      await coinsBloc.syncCoinsStateWithApi();
    }
  }

  Stream<ZCoinStatus> activateRequestedZCoins() async* {
    final zCoinsToActivate = await getRequestedActivatedCoins();
    yield* _activateZCoins(zCoinsToActivate);
  }

  /// Gets coins currently active in API.
  ///
  /// Returns null if there is an error.
  @override
  Future<List<String>> getApiEnabledZCoins() async {
    try {
      final enabledCoins = await api.apiActivatedZCoins();

      return enabledCoins;
    } catch (e) {
      Log(
        'z_coin_activation_repository:getEnabledZCoins',
        'Failed to get enabled ZCoins: $e',
      );
      return null;
    }
  }

  Future<void> cancelAllZCoinActivations() async {
    try {
      final cancelledCoins = await api.cancelAllActivation();
      if (cancelledCoins.isNotEmpty) {
        await removeRequestedActivatedCoins(cancelledCoins);
      }
      await coinsBloc.syncCoinsStateWithApi();
    } catch (e) {
      Log(
        'z_coin_activation_repository:cancelAllZCoinActivations',
        'Failed to cancel ZCoin activations: $e',
      );
    }
  }

  // This is a workaround for the legacy coins bloc. It's not a good practice.
  Future<void> legacyCoinsBlocDisableLocallyCallback(
    String ticker,
  ) async {
    try {
      await api.cancelCoinActivation(ticker);
      await removeRequestedActivatedCoins([ticker]);
    } catch (e) {
      Log(
        'z_coin_activation_repository:cancelAllZCoinActivations',
        'Failed to cancel ZCoin activations: $e',
      );
    }
  }

  @override
  Future<List<String>> outstandingZCoinActivations() async {
    final Set<String> requestedCoins =
        (await getRequestedActivatedCoins()).toSet();

    final Set<String> locallyActiveCoins = await api.localDbActivatedZCoins();

    final Set<String> apiActiveZCoins =
        ((await getApiEnabledZCoins()) ?? []).toSet();

    apiActiveZCoins.removeWhere((coin) => !locallyActiveCoins.contains(coin));

    return requestedCoins.difference(apiActiveZCoins).toList();
  }

  Future<List<Coin>> getKnownZCoins() async {
    final coins = await api.getKnownZCoins();

    final hasTestCoinsEnabled = SettingsBloc().enableTestCoins;

    // Put ZOMBIE first
    final maybeZombieIndex = coins.indexWhere((c) => c.abbr == 'ZOMBIE');
    if (maybeZombieIndex != -1) {
      final zombie = coins.removeAt(maybeZombieIndex);
      coins.insert(0, zombie);
    }

    return coins.where((c) {
      final isTestCoin =
          c.testCoin || appConfig.defaultTestCoins.contains(c.abbr);
      return hasTestCoinsEnabled || !isTestCoin;
    }).toList();
  }

  Stream<ZCoinStatus> activationStatusStream() async* {
    final zCoinsToActivate = await outstandingZCoinActivations();

    // If there are no coins to activate, immediately return.
    if (zCoinsToActivate.isEmpty) return;

    while (zCoinsToActivate.isNotEmpty) {
      for (String coin in zCoinsToActivate) {
        var status = await _getCoinActivationTaskStatus(coin);

        if (status.status == ActivationTaskStatus.active) {
          zCoinsToActivate.remove(coin);
        }
        yield status;
      }

      // If all coins are activated, break the loop to end the stream.
      if (zCoinsToActivate.isEmpty) break;

      // Otherwise, wait a while before checking the statuses again.
      await Future.delayed(Duration(seconds: 5));
    }

    await coinsBloc.syncCoinsStateWithApi();
  }

  Future<List<ZCoinStatus>> getActivationStatusOfAllCoins() async {
    final zCoinsToActivate = await outstandingZCoinActivations();
    final List<Future<ZCoinStatus>> tasks = [];

    for (String coin in zCoinsToActivate) {
      tasks.add(_getCoinActivationTaskStatus(coin));
    }

    return await Future.wait(tasks);
  }

  Future<ZCoinStatus> _getCoinActivationTaskStatus(String coin) async {
    final taskId = await api.getTaskId(coin);
    if (taskId == null) {
      return ZCoinStatus.fromTaskStatus(coin, ActivationTaskStatus.notFound);
    }
    final status = await api.activationTaskStatus(taskId, ticker: coin);

    return status;
  }

  /// Returns a list of activated coins according to our local database.
  ///
  /// This is not related to the activation status of the coins on the API. The
  /// current API activation status could be `true` or `false`.
  Future<List<String>> zCoinsTickersWithPreviousActivation() async {
    final knownZCoins = (await getKnownZCoins()).map((c) => c.abbr).toSet();

    final allActivatedCoins = (await Db.getCoinsFromDb()).toSet();

    final previouslyActivated = knownZCoins.intersection(allActivatedCoins);

    return previouslyActivated.toList();
  }
}
