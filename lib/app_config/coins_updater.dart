import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/utils/log.dart';
import 'package:path_provider/path_provider.dart';

/// Provides methods for fetching coin data either from local assets or a remote Git repository.
///
/// `CoinUpdater` uses a singleton pattern to ensure a single instance throughout the app's lifecycle.
/// It checks first if there is a cached version of the data. If not, it uses the bundled asset.
/// In the background, it tries to fetch the most recent data and cache it for future launches.
///
/// Usage:
/// ```dart
/// final coinUpdater = CoinUpdater();
/// final config = await coinUpdater.getConfig();
/// final coins = await coinUpdater.getCoins();
/// ```
///
/// NB! [coinsRepoBranch] and [coinsRepoUrl] only take effect for the next
/// launch of the app. So 2x restart is needed to switch to a different branch.
///
/// TODO: Implement coin icon fetching.
class CoinUpdater {
  factory CoinUpdater() => _instance;

  CoinUpdater._internal();

  static final CoinUpdater _instance = CoinUpdater._internal();

  /// The branch of the coins repository to use.
  //! QA: change branch name here and then restart twice after logging in.
  static const coinsRepoBranch = 'master';

  static const coinsRepoUrl =
      'https://raw.githubusercontent.com/KomodoPlatform/coins';

  static const isUpdateEnabled = true;

  final String localAssetPathConfig = 'assets/coins_config.json';
  final String localAssetPathCoins = 'assets/coins.json';

  String get remotePathConfig =>
      '$coinsRepoUrl/$coinsRepoBranch/utils/coins_config.json';
  String get remotePathCoins => '$coinsRepoUrl/$coinsRepoBranch/coins';

  String _cachedConfig;
  String _cachedCoins;

  Future<String> _fetchAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<File> _getLocalFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  Future<String> _fetchOrCache(
    String localPath,
    String remoteUrl,
    String cacheName,
    String cacheProperty,
  ) async {
    try {
      if (cacheProperty != null) {
        return cacheProperty;
      }

      File cacheFile = await _getLocalFile(cacheName);

      if (await cacheFile.exists()) {
        cacheProperty = await cacheFile.readAsString();
        return cacheProperty;
      } else {
        String localData = await _fetchAsset(localPath);
        if (isUpdateEnabled) {
          scheduleMicrotask(
            () => _updateCacheInBackground(remoteUrl, cacheFile),
          );
        }
        cacheProperty = localData;
        return localData;
      }
    } catch (e) {
      // If there's an error, first try to return the cached value,
      // if that's null too, then fall back to the local asset.
      if (cacheProperty != null) {
        return cacheProperty;
      } else {
        return await _fetchAsset(localPath);
      }
    }
  }

  void _updateCacheInBackground(String remoteUrl, File cacheFile) async {
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(
      _isolateEntry,
      [remoteUrl, cacheFile.path],
      onExit: receivePort.sendPort,
    );
    receivePort.listen((data) {
      // Close the receive port when the isolate is done
      receivePort.close();

      Log(
        'CoinUpdater',
        'Coin updater updated coins to latest commit on branch '
            '$coinsRepoBranch from $coinsRepoUrl. \n $remoteUrl',
      );
    });
  }

  static void _isolateEntry(List<String> data) async {
    final String remoteUrl = data[0];
    final String filePath = data[1];

    final response = await http.get(Uri.parse(remoteUrl));
    if (response.statusCode == 200) {
      final file = File(filePath);
      file.writeAsString(response.body);
    }
  }

  Future<String> getConfig() async {
    _cachedConfig = await _fetchOrCache(
      localAssetPathConfig,
      remotePathConfig,
      'coins_config_cache.json',
      _cachedConfig,
    );
    return _cachedConfig;
  }

  Future<String> getCoins() async {
    _cachedCoins = await _fetchOrCache(
      localAssetPathCoins,
      remotePathCoins,
      'coins_cache.json',
      _cachedCoins,
    );
    return _cachedCoins;
  }
}
