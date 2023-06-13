import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/coins_bloc.dart';
import '../model/balance.dart';
import '../model/coin.dart';
import '../model/coin_balance.dart';
import '../model/coin_type.dart';
import '../model/error_string.dart';
import '../model/get_send_raw_transaction.dart';
import '../model/withdraw_response.dart';
import '../services/db/database.dart';
import '../services/job_service.dart';
import '../services/mm.dart';
import '../services/mm_service.dart';
import '../utils/log.dart';
import '../utils/utils.dart';
import '../widgets/bloc_provider.dart';

class ZCashBloc implements BlocBase {
  ZCashBloc() {
    _loadPrefs();
  }

  SharedPreferences _prefs;

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    coinsToActivate = _prefs.getStringList('zcoinsToActivate') ?? [];
  }

  void setZcoinsToActivate(List<String> list) {
    _prefs.setStringList('zcoinsToActivate', list);
  }

  // Streams to zcash params download progress
  final StreamController<Map<int, ZTask>> _zcashProgressController =
      StreamController<Map<int, ZTask>>.broadcast();

  List<String> coinsToActivate = [];
  Map<int, ZTask> tasksToCheck = {};

  Sink<Map<int, ZTask>> get _inZcashProgress => _zcashProgressController.sink;

  Stream<Map<int, ZTask>> get outZcashProgress =>
      _zcashProgressController.stream;

  @override
  void dispose() {
    _zcashProgressController.close();
  }

  List<Coin> removeZcashCoins(List<Coin> coins) {
    List<Coin> list =
        coins.where((element) => element.type == CoinType.zhtlc).toList();
    for (var a in list) {
      if (coinsToActivate.where((e) => e == a.abbr).isEmpty) {
        coinsToActivate.add(a.abbr);
      }
    }
    setZcoinsToActivate(coinsToActivate);
    if (list.isNotEmpty) {
      // remove zcash-coins from the main coin list if it exists
      coins.removeWhere((coin) => list.contains(coin));
      if (tasksToCheck[2000] == null) downloadZParams();
      return coins;
    } else {
      return coins;
    }
  }

  String get folder => Platform.isIOS ? '/ZcashParams/' : '/.zcash-params/';

  Future _autoEnableZcashCoins() async {
    final List<Map<String, dynamic>> batch = [];

    final dir = await getApplicationDocumentsDirectory();
    for (String abbr in coinsToActivate) {
      Coin coin = coinsBloc.getKnownCoinByAbbr(abbr);
      final electrum = {
        'userpass': mmSe.userpass,
        'method': 'task::enable_z_coin::init',
        'mmrpc': '2.0',
        'params': {
          'ticker': abbr,
          'activation_params': {
            'mode': {
              'rpc': 'Light',
              'rpc_data': {
                'electrum_servers': Coin.getServerList(coin.serverList),
                'light_wallet_d_servers': coin.lightWalletDServers
              }
            },
            'scan_blocks_per_iteration': 20,
            'scan_interval_ms': 200,
            'zcash_params_path': dir.path + folder
          },
        }
      };
      batch.add(electrum);
    }

    final replies = await MM.batch(batch);
    if (replies.length != coinsToActivate.length) {
      throw Exception(
          'Unexpected number of replies: ${replies.length} != ${coinsToActivate.length}');
    }

    for (int i = 0; i < replies.length; i++) {
      final err = ErrorString.fromJson(replies[i]);

      if (err.error.isNotEmpty) {
        Log('zcash_bloc:283',
            'Error activating ${coinsToActivate[i]}: ${err.error}');

        continue;
      }
      final reply = replies[i];
      int id = reply['result']['task_id'];
      bool taskExists = false;
      for (var element in tasksToCheck.values) {
        if (element.abbr == coinsToActivate[i] &&
            element.type == ZTaskType.ACTIVATING) taskExists = true;
      }
      if (!taskExists) {
        tasksToCheck[id] = ZTask(
          abbr: coinsToActivate[i],
          progress: 0,
          type: ZTaskType.ACTIVATING,
          id: id,
          message: 'Activating',
        );
        jobService.suspend('checkZcashProcessStatus');
        _startActivationStatusCheck();
      }
    }
    _inZcashProgress.add(tasksToCheck);
  }

  startWithdrawStatusCheck(int taskId, String abbr) {
    tasksToCheck[taskId] = ZTask(
      abbr: abbr,
      progress: 0,
      type: ZTaskType.WITHDRAW,
      id: taskId,
      message: 'Withdrawal',
    );
    jobService.suspend('checkZcashProcessStatus');
    _inZcashProgress.add(tasksToCheck);
    _startActivationStatusCheck();
  }

  void _startActivationStatusCheck() {
    jobService.install('checkZcashProcessStatus', 5, (j) async {
      if (!mmSe.running) return;
      if (tasksToCheck.isEmpty) {
        jobService.suspend('checkZcashProcessStatus');
        coinsToActivate.clear();
        setZcoinsToActivate(coinsToActivate);
        return;
      }
      for (var task in tasksToCheck.keys) {
        dynamic res;

        if (tasksToCheck[task].type == ZTaskType.WITHDRAW) {
          res = await MM.batch([
            {
              'userpass': mmSe.userpass,
              'method': 'task::withdraw::status',
              'mmrpc': '2.0',
              'params': {'task_id': tasksToCheck[task].id},
              'id': tasksToCheck[task].id,
            }
          ]);
        } else {
          res = await MM.batch([
            {
              'userpass': mmSe.userpass,
              'method': 'task::enable_z_coin::status',
              'mmrpc': '2.0',
              'params': {'task_id': task},
              'id': task,
            }
          ]);
        }
        res = res.first;
        final err = ErrorString.fromJson(res);
        if (err.error.isNotEmpty) {
          Log('zcash_bloc:293',
              'Error getting ${tasksToCheck[task].abbr} activation status: ${err.error}');
          zcashBloc.tasksToCheck.remove(task);
          _inZcashProgress.add(tasksToCheck);
          continue;
        }

        _zhtlcActivationProgress(res, task);
      }
    });
  }

  void _zhtlcActivationProgress(
      Map<String, dynamic> activationData, int id) async {
    int _progress = 100;
    String _messageDetails = '';
    if (!activationData.containsKey('result')) return;
    String abbr = tasksToCheck[id].abbr;
    String status = activationData['result']['status'];
    dynamic details = activationData['result']['details'];
    Coin coin = coinsBloc.getKnownCoinByAbbr(abbr);

    int blockOffset = 0;
    if (abbr == 'ARRR') {
      blockOffset = coin.protocol.protocolData.checkPointBlock.height;
    }

    // use range from checkpoint block to present
    if (status == 'Ok') {
      if (details.containsKey('error')) {
        Log('zcash_bloc:273', 'Error activating $abbr: ${details['error']}');
        tasksToCheck.remove(id);
        await coinsBloc.syncCoinsStateWithApi(false);
      } else if (tasksToCheck[id].type == ZTaskType.WITHDRAW) {
        tasksToCheck[id].result =
            WithdrawResponse.fromJson(activationData['result']['details']);
        _inZcashProgress.add(tasksToCheck);
        _progress = 100;
        _messageDetails = 'Confirm Withdraw';
      } else {
        await Db.coinActive(coin);
        final bal = Balance(
            address: details['wallet_balance']['address'],
            balance: deci(details['wallet_balance']['balance']['spendable']),
            lockedBySwaps:
                deci(details['wallet_balance']['balance']['unspendable']),
            coin: details['ticker']);
        bal.camouflageIfNeeded();
        final cb = CoinBalance(coin, bal);
        // Before actual coin activation, coinBalance can store
        // coins data (including balanceUSD) loaded from wallet snapshot,
        // created during previous session (#898)
        final double preSavedUsdBalance =
            coinsBloc.getBalanceByAbbr(abbr)?.balanceUSD;
        cb.balanceUSD = preSavedUsdBalance ?? 0;
        coinsBloc.updateOneCoin(cb);

        await coinsBloc.syncCoinsStateWithApi(false);
        coinsBloc.currentCoinActivate(null);
        tasksToCheck.remove(id);
        jobService.suspend('checkZcashProcessStatus');
        _startActivationStatusCheck();
      }
      coinsToActivate.removeWhere((coin) => coin == abbr);
      setZcoinsToActivate(coinsToActivate);
    } else if (status == 'InProgress') {
      if (details == 'ActivatingCoin') {
        _progress = 5;
        _messageDetails = 'Activating $abbr';
      } else if (details == 'RequestingBalance') {
        _progress = 98;
        _messageDetails = 'Requesting $abbr balance';
      } else if (details == 'RequestingWalletBalance') {
        _progress = 98;
        _messageDetails = 'Requesting $abbr balance';
      } else if (details == 'GeneratingTransaction') {
        _progress = 80;
        _messageDetails = 'Generating $abbr Transaction';
      } else if (details.containsKey('UpdatingBlocksCache')) {
        int n = details['UpdatingBlocksCache']['current_scanned_block'] -
            blockOffset;
        int d = details['UpdatingBlocksCache']['latest_block'] - blockOffset;
        _progress = 5 + (n / d * 15).toInt();
        _messageDetails = 'Updating $abbr blocks cache';
      } else if (details.containsKey('BuildingWalletDb')) {
        int n =
            details['BuildingWalletDb']['current_scanned_block'] - blockOffset;
        int d = details['BuildingWalletDb']['latest_block'] - blockOffset;
        _progress = 20 + (n / d * 80).toInt();
        _messageDetails = 'Building $abbr wallet database';
      } else {
        _progress = 5;
        _messageDetails = 'Activating $abbr';
      }
    } else {
      tasksToCheck.remove(id);
      coinsToActivate.removeWhere((coin) => coin == abbr);
      setZcoinsToActivate(coinsToActivate);
      Log('zcash_bloc:273', 'Error activating $abbr: unexpected error');
    }
    if (tasksToCheck[id] != null) {
      tasksToCheck[id].progress = _progress;
      tasksToCheck[id].message = _messageDetails;
    }
    _inZcashProgress.add(tasksToCheck);
  }

  Future<void> downloadZParams() async {
    if (coinsToActivate.isEmpty) return;
    final dir = await getApplicationDocumentsDirectory();
    Directory zDir = Directory(dir.path + folder);
    if (zDir.existsSync() &&
        MMService.dirStatSync(zDir.path, endsWith: '') > 50) {
      _autoEnableZcashCoins();
      return;
    } else if (!zDir.existsSync()) {
      zDir.createSync();
    }

    final params = [
      'https://z.cash/downloads/sapling-spend.params',
      'https://z.cash/downloads/sapling-output.params',
    ];

    int _received = 0;
    int _totalDownloadSize = 0;
    for (var param in params) {
      final List<int> _bytes = [];

      StreamedResponse _response;
      _response = await Client().send(Request('GET', Uri.parse(param)));
      _totalDownloadSize += _response.contentLength ?? 0;
      tasksToCheck[2000] = ZTask(
        message: 'Downloading Zcash params',
        progress: 0,
        type: ZTaskType.DOWNLOADING,
        id: 2000,
      );
      // 2000 is the task id for downloading z-params{just a random number}
      _inZcashProgress.add(tasksToCheck);
      _response.stream.listen((value) {
        _bytes.addAll(value);
        _received += value.length;
        tasksToCheck[2000].progress =
            ((_received / _totalDownloadSize) * 100).toInt();
        _inZcashProgress.add(tasksToCheck);
      }).onDone(() async {
        final file = File(zDir.path + param.split('/').last);
        if (!file.existsSync()) await file.create();
        await file.writeAsBytes(_bytes);
        _inZcashProgress.add(tasksToCheck);
        if (_received / _totalDownloadSize == 1) {
          tasksToCheck.remove(2000);
          _autoEnableZcashCoins();
        }
      });
    }
  }

  void cancelTask(ZTask task) async {
    bool isEnable = task.type == ZTaskType.ACTIVATING;
    await MM.batch([
      {
        'userpass': mmSe.userpass,
        'method':
            isEnable ? 'task::enable_z_coin::cancel' : 'task::withdraw::cancel',
        'mmrpc': '2.0',
        'params': {'task_id': task.id},
        'id': task.id,
      }
    ]);
    if (isEnable) {
      coinsToActivate.removeWhere((coin) => coin == task.abbr);
    }
    if (task.type == ZTaskType.DOWNLOADING) coinsToActivate = [];
    setZcoinsToActivate(coinsToActivate);
    tasksToCheck.remove(task.id);
    _inZcashProgress.add(tasksToCheck);
  }

  void confirmWithdraw(ZTask task) async {
    await ApiProvider().postRawTransaction(
      mmSe.client,
      GetSendRawTransaction(coin: task.abbr, txHex: task.result.txHex),
    );
    coinsBloc.updateCoinBalances();

    tasksToCheck.remove(task.id);
    _inZcashProgress.add(tasksToCheck);
  }
}

class ZTask {
  String abbr;
  String message;
  ZTaskType type;
  int progress;
  int id;
  dynamic result;

  ZTask({
    this.abbr,
    this.message,
    this.type,
    this.progress,
    this.result,
    this.id,
  });
}

enum ZTaskType { WITHDRAW, ACTIVATING, DOWNLOADING }

ZCashBloc zcashBloc = ZCashBloc();
