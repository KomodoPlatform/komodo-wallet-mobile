import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_type.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_notifications.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_activation_prefs.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_status.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/services/music_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

class ZCoinActivationApi {
  ZCoinActivationApi();

  final String _baseUrl = mmSe.url;
  String get _userpass => mmSe.userpass;

  Directory get zCashParamsDirectory => Directory(
        (applicationDocumentsDirectorySync.path + '/zcash-params'),
      );

  bool _paramsDownloaded = false;

  Map<String, int> firstScannedBlocks = {};

  void resetFirstScannedBlocks() => firstScannedBlocks = {};

  Future<int> userSelectedZhtlcSyncStartTimestamp() async {
    final zhtlcActivationPrefs = await loadZhtlcActivationPrefs();
    SyncType zhtlcSyncType = zhtlcActivationPrefs['zhtlcSyncType'];
    DateTime savedZhtlcSyncStartDate =
        zhtlcActivationPrefs['zhtlcSyncStartDate'];

    return (zhtlcSyncType == SyncType.specifiedDate
                ? savedZhtlcSyncStartDate
                : zhtlcSyncType == SyncType.fullSync
                    ? DateTime.utc(2000, 1, 1)
                    : DateTime.now().subtract(Duration(days: 2)))
            .millisecondsSinceEpoch ~/
        1000;
  }

  /// Creates a new activation task for the given coin.
  Future<int> initiateActivation(
    String ticker, {
    bool noSyncParams = false,
  }) async {
    await musicService.play(MusicMode.ACTIVE);
    await downloadZParams();

    Coin coin = coinsBloc.getKnownCoinByAbbr(ticker);

    Map<String, dynamic> rpcData = {
      'electrum_servers': Coin.getServerList(coin.serverList),
      'light_wallet_d_servers': coin.lightWalletDServers
    };

    if (!noSyncParams) {
      rpcData['sync_params'] = {
        'date': (await userSelectedZhtlcSyncStartTimestamp())
      };
    }

    Map<String, dynamic> activationParams = {
      'mode': {'rpc': 'Light', 'rpc_data': rpcData},
      'scan_blocks_per_iteration': 150,
      'scan_interval_ms': 150,
      'zcash_params_path': zCashParamsDirectory.path,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userpass': _userpass,
        'method': 'task::enable_z_coin::init',
        'mmrpc': '2.0',
        'params': {
          'ticker': ticker,
          'activation_params': activationParams,
        },
      }),
    );

    if (response.statusCode == 200) {
      final result =
          (jsonDecode(response.body)['result'] as Map<String, dynamic>);
      final taskId = result['task_id'];

      await setTaskId(ticker, taskId);

      return taskId;
    } else {
      await _removeCoinTaskId(ticker).onError((error, stackTrace) {});
      throw Exception('Failed to initiate activation: ${response.toString()}');
    }
  }

  Future<void> cancelActivationTask(int taskId) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userpass': _userpass,
        'method': 'task::enable_z_coin::cancel',
        'mmrpc': '2.0',
        'params': {
          'task_id': taskId,
        },
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      Log(
        'z_coin_activation_api:cancelActivation',
        'ZCoin Activation Cancel Response: ${responseBody.toString()}',
      );

      // Success can give error as well, like:
      // "error": "Task is finished already",
      // if (responseBody.containsKey('error')) {
      // Log('z_coin_activation_api:cancelActivation',
      //     'ZCoin Activation Cancel Error: ${responseBody['error']}');
      // }
    } else {
      throw Exception('Failed to cancel activation: ${response.toString()}');
    }
  }

  Future<void> cancelCoinActivation(String ticker) async {
    int taskId = await getTaskId(ticker);

    if (taskId == null) return;

    await cancelActivationTask(taskId);
    await _removeCoinTaskId(ticker);
    firstScannedBlocks.remove(ticker);
  }

  Future<List<String>> cancelAllActivation() async {
    List<Coin> knownZCoins = await getKnownZCoins();
    List<String> activatedCoins = await apiActivatedZCoins();
    List<String> cancelledCoins = [];

    for (Coin coin in knownZCoins) {
      String ticker = coin.abbr;
      int coinTaskId = await getTaskId(ticker);

      // Check if coin is already activated
      if (activatedCoins.contains(ticker)) {
        continue;
      }

      ZCoinStatus taskStatus =
          await activationTaskStatus(coinTaskId, ticker: ticker);

      // Check if task status is active
      if (taskStatus.status == ActivationTaskStatus.active) {
        continue;
      }

      // Attempt to cancel the activation
      try {
        await cancelCoinActivation(ticker);

        cancelledCoins.add(ticker);
      } catch (e) {
        Log(
          'z_coin_activation_api:cancelAllActivation',
          'Failed to cancel activation for $ticker: $e',
        );
      }
    }

    return cancelledCoins;
  }

  Future<int> getTaskId(String abbr) async {
    final storage = FlutterSecureStorage();
    return int.tryParse(await storage.read(key: await taskIdKey(abbr)) ?? '');
  }

  Future<void> setTaskId(String abbr, int taskId) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: await taskIdKey(abbr), value: taskId.toString());
  }

  Stream<ZCoinStatus> activateCoin(
    String ticker, {
    bool resync = false,
  }) async* {
    int coinTaskId = await getTaskId(ticker);
    ZCoinStatus taskStatus;
    final isAlreadyActivated = (await apiActivatedZCoins()).contains(ticker);

    if (!resync) {
      taskStatus = coinTaskId == null
          ? ZCoinStatus.fromTaskStatus(
              ticker,
              isAlreadyActivated
                  ? ActivationTaskStatus.active
                  : ActivationTaskStatus.notFound,
            )
          : await activationTaskStatus(coinTaskId, ticker: ticker);
      final isActivatedOnBackend =
          (isAlreadyActivated || taskStatus.isActivated);

      final isRegistered = coinsBloc.getBalanceByAbbr(ticker) != null;

      if (isActivatedOnBackend) {
        yield taskStatus;

        if (!isRegistered) {
          final coin = (await coins)[ticker];
          await coinsBloc.setupCoinAfterActivation(coin);
        }

        return;
      }
    }

    ZCoinStatus lastEmittedStatus;

    coinTaskId = await initiateActivation(ticker, noSyncParams: resync);

    lastEmittedStatus = await activationTaskStatus(coinTaskId, ticker: ticker);

    yield lastEmittedStatus;

    while (true) {
      coinTaskId = await getTaskId(ticker);
      taskStatus = await activationTaskStatus(coinTaskId, ticker: ticker);

      final shouldEmitStatus = lastEmittedStatus == null ||
          lastEmittedStatus.status != taskStatus.status ||
          lastEmittedStatus.progress <= taskStatus.progress;

      if (shouldEmitStatus) {
        lastEmittedStatus = taskStatus;
        yield taskStatus;
      }

      if (taskStatus.status == ActivationTaskStatus.active ||
          taskStatus.status == ActivationTaskStatus.notFound) {
        ZCoinProgressNotifications.clear();

        return;
      }

      await Future.delayed(Duration(seconds: 10));
    }
  }

  Future<ZCoinStatus> activationTaskStatus(
    int taskId, {
    @required String ticker,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: json.encode({
        'userpass': _userpass,
        'method': 'task::enable_z_coin::status',
        'mmrpc': '2.0',
        'params': {
          'task_id': taskId,
          'forget_if_finished': true,
        },
      }),
    );
    final body = jsonDecode(response.body);

    Log('activationTaskStatus', 'Z Coin activation status response: $body');

    final errorType = body['error_type'];
    final statusCode = response.statusCode;
    final isNoTaskExists = statusCode == 400 || errorType == 'NoSuchTask';
    final result = body['result'] as Map<String, dynamic>;

    if (isNoTaskExists) {
      return ZCoinStatus.fromTaskStatus(ticker, ActivationTaskStatus.notFound);
    } else if (errorType != null || statusCode != 200 || result == null) {
      return ZCoinStatus.fromTaskStatus(ticker, ActivationTaskStatus.failed);
    }

    final apiStatus = result['status'] as String;

    if (apiStatus == 'Failed') {
      return ZCoinStatus(
        coin: ticker,
        status: ActivationTaskStatus.failed,
        message: result['error'] as String,
      );
    }

    final status =
        await _parseZCoinProgress(responseBody: body, ticker: ticker);

    if (status?.isActivated ?? false) {
      await _removeCoinTaskId(ticker);
    }

    Log(
      'activationTaskStatus',
      'Z Coin activation status (Progress=${status.progress}) ($apiStatus) response: ${result.toString()}',
    );

    if (status != null) {
      return status;
    }

    return ZCoinStatus.fromTaskStatus(ticker, ActivationTaskStatus.notFound);
  }

  Future<void> _removeCoinTaskId(String ticker) async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: await taskIdKey(ticker));
  }

  Future<List<String>> apiActivatedZCoins() async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userpass': _userpass,
        'method': 'get_enabled_coins',
        'mmrpc': '2.0',
      }),
    );

    if (response.statusCode == 200) {
      final enabledCoins =
          (jsonDecode(response.body)['result']['coins'] as List)
              .map((e) => e['ticker'] as String)
              .toSet();

      final knownZCoins = (await getKnownZCoins()).map((c) => c.abbr).toSet();

      return knownZCoins.intersection(enabledCoins).toList();
    } else {
      throw Exception('Failed to get activated zcoins');
    }
  }

  Future<Set<String>> localDbActivatedZCoins() async {
    return (await getKnownZCoins())
        .where((c) => c.isActive)
        .map((c) => c.abbr)
        .toSet();
  }

  Future<List<Coin>> getKnownZCoins() async {
    final _coins = await coins;

    if (_coins == null) {
      await pauseUntil(() async => (await coins) != null);
    }

    return (_coins ?? await coins)
        .values
        .where((c) => c.type == CoinType.zhtlc)
        .toList();
  }

  Future<void> downloadZParams() async {
    if (_paramsDownloaded) return;

    final doesZcashDirectoryExist = await zCashParamsDirectory.exists();

    final isZcashDirBigEnough = (await MMService.getDirectorySize(
          zCashParamsDirectory.path,
          endsWith: '',
          allowCache: false,
        )) >
        1;

    if (!doesZcashDirectoryExist) {
      await zCashParamsDirectory.create(recursive: true);
    }

    if (doesZcashDirectoryExist && isZcashDirBigEnough) {
      _paramsDownloaded = true;
      return;
    }

    final paramUrls = [
      'https://z.cash/downloads/sapling-spend.params',
      'https://z.cash/downloads/sapling-output.params',
    ];

    final futures = paramUrls.map((param) async {
      final client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(Uri.parse(param));
      final response = await request.close();

      final wasSuccessful = response.statusCode.toString().startsWith('2');

      if (!wasSuccessful) {
        final exceptionMessage = 'Failed to download $param: '
            '${response.statusCode} ${response.reasonPhrase}';

        Log('ZCoinActivationApi:downloadZParams', exceptionMessage);
        throw Exception(exceptionMessage);
      }

      final bytes = await consolidateHttpClientResponseBytes(response);

      final file =
          File('${zCashParamsDirectory.path}/${param.split('/').last}');
      await file.writeAsBytes(bytes, flush: true);
    });

    await Future.wait(futures);

    _paramsDownloaded = true;
  }

  Future<ZCoinStatus> _parseZCoinProgress({
    Map<String, dynamic> responseBody,
    String ticker,
  }) async {
    int _progress = 5;
    String _messageDetails = 'Activating $ticker';
    if (!responseBody.containsKey('result')) return null;

    final result = responseBody['result'] is Map<String, dynamic>
        ? responseBody['result']
        : jsonDecode(responseBody['result']) as Map<String, dynamic>;
    String status = result['status'];
    dynamic details = result['details'];

    // use range from checkpoint block to present
    if (status == 'Ok') {
      if (details.containsKey('error')) {
        Log('zcash_bloc:273', 'Error activating $ticker: ${details['error']}');
      }

      return ZCoinStatus(
        coin: ticker,
        status: ActivationTaskStatus.active,
        progress: 1,
      );
    } else if (status == 'InProgress') {
      if (details == 'ActivatingCoin') {
        _progress = 5;
        _messageDetails = 'Activating $ticker';
      } else if (details == 'RequestingBalance') {
        _progress = 98;
        _messageDetails = 'Requesting $ticker balance';
      } else if (details == 'RequestingWalletBalance') {
        _progress = 98;
        _messageDetails = 'Requesting $ticker balance';
      } else if (details == 'GeneratingTransaction') {
        _progress = 80;
        _messageDetails = 'Generating $ticker Transaction';
      } else if (details.containsKey('UpdatingBlocksCache') ||
          details.containsKey('BuildingWalletDb')) {
        // Determine whether we are in the building phase
        bool isBuildingPhase = details.containsKey('BuildingWalletDb');

        // Select appropriate details based on the phase
        dynamic currentDetails = details[
            isBuildingPhase ? 'BuildingWalletDb' : 'UpdatingBlocksCache'];

        // Fetch block details
        int latestBlock = currentDetails['latest_block'];
        int currentScannedBlock = currentDetails['current_scanned_block'];

        // If it's the first scan for this ticker, store the current block as the first scanned block
        if (!firstScannedBlocks.containsKey(ticker) ||
            currentScannedBlock < firstScannedBlocks[ticker]) {
          firstScannedBlocks[ticker] = currentScannedBlock;
        }

        // Retrieve the first scanned block for this ticker
        int firstScannedBlock = firstScannedBlocks[ticker];

        // Compute number of blocks scanned so far and total blocks
        int numBlocksScanned = currentScannedBlock - firstScannedBlock;
        int totalBlocks = latestBlock - firstScannedBlock;

        if (totalBlocks <= 0) totalBlocks = numBlocksScanned;
        if (totalBlocks <= 0) totalBlocks = 1;

        _progress = isBuildingPhase
            ? (20 + ((numBlocksScanned / totalBlocks) * 80).toInt())
            : (5 + ((numBlocksScanned / totalBlocks) * 15).toInt());

        _messageDetails = isBuildingPhase
            ? 'Building $ticker wallet database'
            : 'Updating $ticker blocks cache';
      }

      return ZCoinStatus(
        coin: ticker,
        status: ActivationTaskStatus.inProgress,
        progress: double.parse((_progress / 100).toStringAsPrecision(4)),
        message: _messageDetails,
      );
    } else if (status == 'Error') {
      return ZCoinStatus(
        coin: ticker,
        status: ActivationTaskStatus.failed,
        message: details['error'] as String,
      );
    } else {
      Log('zcash_bloc:_parseZCoinProgress', 'Unknown status: $status');
      return null;
    }
  }

  Future<void> removeTaskId(String ticker) async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: await taskIdKey(ticker));
  }

  Future<String> taskIdKey(String ticker) async {
    final currentWallet = await Db.getCurrentWallet();
    if (currentWallet == null) return null;

    return '${currentWallet.id}_task_id_$ticker';
  }
}
