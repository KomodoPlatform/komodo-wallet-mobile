import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_type.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_notifications.dart';
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

  String get folder => Platform.isIOS ? '/ZcashParams/' : '/.zcash-params/';

  bool _paramsDownloaded = false;

  /// Creates a new activation task for the given coin.
  Future<int> initiateActivation(String ticker) async {
    await musicService.play(MusicMode.ACTIVE);
    await downloadZParams();

    final dir = await applicationDocumentsDirectory;
    Coin coin = coinsBloc.getKnownCoinByAbbr(ticker);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userpass': _userpass,
        'method': 'task::enable_z_coin::init',
        'mmrpc': '2.0',
        'params': {
          'ticker': ticker,
          'activation_params': {
            'mode': {
              'rpc': 'Light',
              'rpc_data': {
                'electrum_servers': Coin.getServerList(coin.serverList),
                'light_wallet_d_servers': coin.lightWalletDServers
              }
            },
            'scan_blocks_per_iteration': 150,
            'scan_interval_ms': 150,
            'zcash_params_path': dir.path + folder
          },
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

  Future<int> getTaskId(String abbr) async {
    final storage = FlutterSecureStorage();
    return int.tryParse(await storage.read(key: await taskIdKey(abbr)) ?? '');
  }

  Future<void> setTaskId(String abbr, int taskId) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: await taskIdKey(abbr), value: taskId.toString());
  }

  Stream<ZCoinStatus> activateCoin(String ticker) async* {
    int coinTaskId = await getTaskId(ticker);

    final isAlreadyActivated = (await activatedZCoins()).contains(ticker);

    ZCoinStatus taskStatus = coinTaskId == null
        ? ZCoinStatus.fromTaskStatus(
            ticker,
            isAlreadyActivated
                ? ActivationTaskStatus.active
                : ActivationTaskStatus.notFound)
        : await activationTaskStatus(coinTaskId, ticker: ticker);

    final isActivatedOnBackend = (isAlreadyActivated || taskStatus.isActivated);

    final isRegistered = coinsBloc.getBalanceByAbbr(ticker) != null;

    if (isActivatedOnBackend) {
      yield taskStatus;

      if (!isRegistered) {
        final coin = (await coins)[ticker];
        await coinsBloc.setupCoinAfterActivation(coin);
      }

      return;
    }

    ZCoinStatus lastEmittedStatus;

    coinTaskId = await initiateActivation(ticker);

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
        // yield taskStatus;
        yield taskStatus;
      }

      final isTaskActive = taskStatus.status == ActivationTaskStatus.active;
      final isTaskNotFound = taskStatus.status == ActivationTaskStatus.notFound;

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

    Log('activationTaskStatus',
        'Z Coin activation status (Progress=${status.progress}) ($apiStatus) response: ${result.toString()}');

    if (status != null) {
      return status;
    }

    return ZCoinStatus.fromTaskStatus(ticker, ActivationTaskStatus.notFound);
  }

  Future<void> _removeCoinTaskId(String ticker) async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: await taskIdKey(ticker));
  }

  double calculateProgressPercentage(Map<String, dynamic> details) {
    if (details != null && details.containsKey('BuildingWalletDb')) {
      final buildingDbDetails =
          details['BuildingWalletDb'] as Map<String, dynamic>;
      if (buildingDbDetails != null &&
          buildingDbDetails.containsKey('current_scanned_block') &&
          buildingDbDetails.containsKey('latest_block')) {
        final currentBlock = buildingDbDetails['current_scanned_block'] as int;
        final latestBlock = buildingDbDetails['latest_block'] as int;

        return currentBlock / latestBlock;
      }
    }
    return null;
  }

  Future<List<String>> activatedZCoins() async {
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
              .toList();

      final knownZCoins = await getKnownZCoins();

      final activatedZCoins = knownZCoins
          .where((c) => enabledCoins.contains(c.abbr) || c.isActive)
          .map((c) => c.abbr)
          .toList();

      return activatedZCoins;
    } else {
      throw Exception('Failed to get activated zcoins');
    }
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

    final dir = await applicationDocumentsDirectory;
    final zDir = Directory(dir.path + folder);

    final doesZcashDirectoryExist = await zDir.exists();

    final isZcashDirBigEnough =
        (await MMService.getDirectorySize(zDir.path, endsWith: '')) > 1;

    if (!doesZcashDirectoryExist) {
      await zDir.create();
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

      final bytes = await consolidateHttpClientResponseBytes(response);

      final file = File('${zDir.path}/${param.split('/').last}');
      await file.writeAsBytes(bytes);
    });

    await Future.wait(futures);

    _paramsDownloaded = true;
  }

  Future<ZCoinStatus> _parseZCoinProgress({
    Map<String, dynamic> responseBody,
    String ticker,
  }) async {
    int _progress = 100;
    String _messageDetails = '';
    if (!responseBody.containsKey('result')) return null;

    final result = responseBody['result'] is Map<String, dynamic>
        ? responseBody['result']
        : jsonDecode(responseBody['result']) as Map<String, dynamic>;
    String status = result['status'];
    dynamic details = result['details'];
    Coin coin = coinsBloc.getKnownCoinByAbbr(ticker);

    int blockOffset = 0;
    if (coin.type == CoinType.zhtlc) {
      blockOffset = coin.protocol.protocolData.checkPointBlock?.height ?? 0;
    }

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
      } else if (details.containsKey('UpdatingBlocksCache')) {
        int n = details['UpdatingBlocksCache']['current_scanned_block'] -
            blockOffset;
        int d = details['UpdatingBlocksCache']['latest_block'] - blockOffset;
        _progress = 5 + (n / d * 15).toInt();
        _messageDetails = 'Updating $ticker blocks cache';
      } else if (details.containsKey('BuildingWalletDb')) {
        int n =
            details['BuildingWalletDb']['current_scanned_block'] - blockOffset;
        int d = details['BuildingWalletDb']['latest_block'] - blockOffset;
        _progress = 20 + (n / d * 80).toInt();
        _messageDetails = 'Building $ticker wallet database';
      } else {
        _progress = 5;
        _messageDetails = 'Activating $ticker';
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
