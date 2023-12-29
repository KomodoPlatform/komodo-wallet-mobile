import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/coin_ci.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

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
  final String localAssetPathCIConfig = 'assets/coins_ci.json';
  final String localAssetPathConfig = 'assets/coins_config.json';
  final String localAssetPathCoins = 'assets/coins.json';

  String _cachedConfig;
  String _cachedCoins;
  CoinsCI _coinsCI;

  Future<String> _fetchAsset(String path) =>
      rootBundle.loadString(path, cache: false);

  Future<String> _fetchCoinFileOrAsset(UpdateCacheParams params) async {
    File cacheFile;
    String property;

    try {
      try {
        cacheFile = await getLocalFile(params.cacheFileName);

        final maybeCacheValue = await compute<String, String>(
          _tryReadValidJsonFile,
          cacheFile.path,
        );

        property = maybeCacheValue ?? property;
      } catch (e) {
        Log(
          'CoinUpdater',
          'Error reading coin config cache file: ${e.toString()}',
        );
      }

      property ??= await _fetchAsset(params.localPath);

      return property;
    } catch (e) {
      Log('CoinUpdater', 'Error fetching or caching ${params.cacheKey}: $e');
      rethrow;
    } finally {
      if (_coinsCI?.runtimeUpdatesEnabled ?? true) {
        _startUpdateCacheInBackground(
            params.copyWith(localPath: cacheFile?.path));
      }
    }
  }

  void _startUpdateCacheInBackground(UpdateCacheParams params) async {
    try {
      Log('CoinUpdater', 'Updating coins in background...');
      await compute<UpdateCacheParams, void>(
        _updateFileFromServer,
        params,
      );

      Log(
        'CoinUpdater',
        'Coin updater updated coins to latest commit'
            ' from ${params.remoteUrl}. Changes will take effect on next app launch.',
      );
    } catch (e) {
      Log('CoinUpdater', 'Error updating coins in background: $e');
    }
  }

  Future<String> getConfig() async {
    final String remotePathConfig =
        await _getAssetRemotePath(localAssetPathConfig);
    return _cachedConfig ??= await _fetchCoinFileOrAsset(
      UpdateCacheParams(
        localPath: localAssetPathConfig,
        remoteUrl: remotePathConfig,
        cacheFileName: 'coins_config_cache.json',
        cacheKey: 'config',
      ),
    );
  }

  Future<String> getCoins() async {
    final String remotePathCoins =
        await _getAssetRemotePath(localAssetPathCoins);
    return _cachedCoins ??= await _fetchCoinFileOrAsset(
      UpdateCacheParams(
        localPath: localAssetPathCoins,
        remoteUrl: remotePathCoins,
        cacheFileName: 'coins_cache.json',
        cacheKey: 'coins',
      ),
    );
  }

  Future<String> _getAssetRemotePath(String localPath) async {
    _coinsCI ??= await _loadCoinsCIConfig();
    final mappedFile = _coinsCI?.mappedFiles[localPath];
    final url = _coinsCI?.coinsRepoUrl;
    final branch = _coinsCI?.coinsRepoBranch;
    return '$url/contents/$mappedFile?ref=$branch';
  }

  Future<CoinsCI> _loadCoinsCIConfig() async {
    final String coinsCI = await _fetchAsset(localAssetPathCIConfig);
    final coinsCIResponse = jsonDecode(coinsCI);
    return CoinsCI.fromJson(coinsCIResponse);
  }
}

class UpdateCacheParams {
  final String localPath;
  final String remoteUrl;
  final String cacheFileName;
  final String cacheKey;

  UpdateCacheParams({
    @required this.localPath,
    @required this.remoteUrl,
    @required this.cacheFileName,
    @required this.cacheKey,
  });

  UpdateCacheParams copyWith({
    String localPath,
    String remoteUrl,
    String cacheFileName,
    String cacheKey,
  }) {
    return UpdateCacheParams(
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      cacheFileName: cacheFileName ?? this.cacheFileName,
      cacheKey: cacheKey ?? this.cacheKey,
    );
  }
}

/// Isolate-safe method for returning the contents of a JSON file if it is valid
Future<String> _tryReadValidJsonFile(String path) async {
  try {
    final contents = await File(path).readAsString();

    if (!_isJsonValid(contents)) return null;

    return contents;
  } catch (e) {
    return null;
  }
}

/// An isolate-safe method for checking if a string is valid JSON.
bool _isJsonValid(String json) {
  try {
    if (json?.isEmpty ?? true) return false;

    jsonDecode(json);
    return true;
  } catch (e) {
    return false;
  }
}

Future<File> getLocalFile(String filename) async {
  final directory = await applicationDocumentsDirectory;
  return File('${directory.path}/config_updates/$filename');
}

/// Isolate-safe method for fetching and updating a JSON file from a
/// remote server.
Future<void> _updateFileFromServer(UpdateCacheParams params) async {
  try {
    final headers = {
      'Accept': 'application/vnd.github.v3+json',
    };
    final apiRespose =
        await http.get(Uri.parse(params.remoteUrl), headers: headers);
    if (apiRespose.statusCode != 200 || !_isJsonValid(apiRespose.body)) {
      return;
    }

    final apiJson = jsonDecode(apiRespose.body);
    final String downloadUrl = apiJson['download_url'];
    final fileResponse = await http.get(Uri.parse(downloadUrl));
    if (fileResponse.statusCode != 200 || !_isJsonValid(fileResponse.body)) {
      return;
    }

    final file = File(params.localPath);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    file.writeAsStringSync(fileResponse.body, flush: true);
  } catch (e) {
    print('Error in isolate: $e');

    rethrow;
  }
}
