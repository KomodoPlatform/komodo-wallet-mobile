import 'package:komodo_dex/services/db/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mixin for ZCoinActivationRepository
mixin RequestedZCoinsStorage {
  Future<String> _getRequestedActivationKey() async {
    final walletId = (await Db.getCurrentWallet()).id;
    if (walletId == null) throw Exception('No current wallet');
    return 'z-coin-activation-requested-$walletId';
  }

  Future<List<String>> getRequestedActivatedCoins() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getRequestedActivationKey();

    final requestedCoins = (prefs.getStringList(key)) ?? [];

    return requestedCoins;
  }

  Future<void> setRequestedActivatedCoins(List<String> coins) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getRequestedActivationKey();

    await prefs.setStringList(key, coins);
  }

  Future<void> removeRequestedActivatedCoins(List<String> coins) async {
    final currentRequestedCoins = (await getRequestedActivatedCoins()).toSet();

    final coinsToRemove = coins.toSet().intersection(currentRequestedCoins);
    if (coinsToRemove.isEmpty) return;

    await setRequestedActivatedCoins(
      currentRequestedCoins.difference(coinsToRemove).toList(),
    );
  }

  Future<void> addRequestedActivatedCoins(List<String> coins) async {
    final currentRequestedCoins = (await getRequestedActivatedCoins()).toSet();

    final updatedList = coins.toSet().union(currentRequestedCoins);
    if (updatedList == currentRequestedCoins) return;

    await setRequestedActivatedCoins(updatedList.toList());
  }

  /// Returns true if all requested coins are enabled.
  /// Returns false if not all requested coins are enabled.
  /// Returns null if no coins are requested.
  Future<bool> isAllRequestedZCoinsEnabled() async {
    final requestedCoins = await getRequestedActivatedCoins();

    return requestedCoins.isEmpty
        ? null
        : (await outstandingZCoinActivations()).isEmpty;
  }

  Future<List<String>> outstandingZCoinActivations();

  Future<List<String>> getApiEnabledZCoins();
}
