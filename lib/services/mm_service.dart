import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show File, Platform, Process;

import 'package:flutter/foundation.dart';
import 'package:komodo_dex/model/version_mm2.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart'
    show EventChannel, MethodChannel, rootBundle, SystemChannels;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/base_service.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_init.dart';
import 'package:komodo_dex/model/config_mm2.dart';
import 'package:komodo_dex/model/get_balance.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Singleton shorthand for `MMService()`, Market Maker API.
MMService mmSe = MMService._internal();

/// Interface to Market Maker, https://developers.atomicdex.io/
class MMService {
  factory MMService() => mmSe;
  MMService._internal();

  List<dynamic> balances = <dynamic>[];
  Process mm2Process;
  List<Coin> coins = <Coin>[];

  /// Switched on when we hear from MM.
  bool get running => _running;
  bool _running = false;

  String url = 'http://localhost:7783';
  String userpass = '';
  Stream<List<int>> streamSubscriptionStdout;

  /// MM commit hash
  String mmVersion;

  // The date corresponding to the MM commit hash, YYYY-MM-DD
  String mmDate;

  /// Our name and version
  String gui;

  /// We're using the netid of 7777 currently
  /// But it's possible in theory to connect the UI to MM running on a different netid
  int netid = 7777;

  /// Effective memory used by the application, MiB
  /// As of now it is specific to iOS
  int footprint;

  /// Resident set size of the application, MiB
  /// As of now it is specific to iOS
  int rs;

  /// Number of files used by the application (iOS)
  int files;

  /// Time when the metrics were last updated
  int metricsLM;

  /// Channel to native code.
  static MethodChannel nativeC = MethodChannel(
      Platform.isAndroid ? 'com.komodoplatform.atomicdex/nativeC' : 'mm2');

  /// Log entries streamed from native code.
  /// MM log is coming that way on iOS.
  static const EventChannel logC = EventChannel('AtomicDEX/logC');
  Client client = http.Client();

  /// Maps a $year-$month-$day date to the corresponding log file.
  /// The current date time can fluctuate (due to time correction services, for instance)
  /// so the map helps us with always picking the file that corresponds to the actual date.
  final Map<String, FileAndSink> _logs = {};

  Future<void> _trafficMetrics() async {
    dynamic metrics = await MM.getMetricsMM2(BaseService(method: 'metrics'));
    // I/flutter (23292): metrics: {metrics: [{key: tx.history.request.count, labels: {client: electrum, coin: DEX, method: blockchain.scripthash.get_history}, type: counter, value: 1}, {key: rpc_client.response.count, labels: {client: electrum, coin: RICK}, type: counter, value: 13}, {key: tx.history.response.total_length, labels: {client: electrum, coin: KMD, method: blockchain.scripthash.get_history}, type: counter, value: 290}, {key: tx.history.request.count, labels: {client: electrum, coin: KMD, method: blockchain.scripthash.get_history}, type: counter, value: 1}, {key: rpc_client.request.count, labels: {client: electrum, coin: DEX}, type: counter, value: 14}, {key: tx.history.response.total_length, labels: {client: electrum, coin: RICK, method: blockchain.scripthash.get_history}, type: counter, value: 177}, {key: rpc_client.request.count, labels: {client: electrum, coin: BTC}, type: counter, value: 14}, {key: rpc_client.response.count, labels: {client: electrum, coin: BTC}, type: counter, value: 13}, {key: tx.history.response.c

    if (metrics is! Map<String, dynamic>) return;
    metrics = metrics['metrics'];
    if (metrics is! List<dynamic>) return;

    final Map<String, int> traffic = {};
    for (var item in metrics) {
      if (item is! Map<String, dynamic>) continue;
      if (item['key'] is! String) continue;
      if (item['value'] is! int) continue;
      final String key = item['key'];
      final int value = item['value'];
      if (key == 'rpc_client.traffic.in' ||
          key == 'rpc_client.traffic.out' ||
          key == 'tx.history.response.total_length') {
        traffic[key] = (traffic[key] ?? 0) + value;
      } else {
        // Uncomment to see what other metrics keys we have from MM:
        //Log('mm_service:123', 'metrics key ' + item['key']);
      }
    }
    Log('mm_service:126', 'MM traffic: $traffic');
    // ^^ The idea here is to send the traffic to a decentralized database for further analysis
    // (but we don't have one yet)
  }

  /// Setup and maintain the measurement of application metrics: network traffic, CPU usage, etc.
  void metrics() {
    jobService.install('metrics', 31.4, (j) async {
      try {
        if (mmSe.running) await _trafficMetrics();
      } catch (ex, trace) {
        Log.println('mm_service:137', '_trafficMetrics error: $ex, $trace');
      }
      // Not implemented on Android YET.
      if (Platform.isIOS) {
        final js = await nativeC.invokeMethod<String>('metrics');
        //Log('mm_service:142', 'metrics: $js');
        final Map<String, dynamic> mjs = json.decode(js);
        footprint = mjs['footprint'];
        rs = mjs['rs'];
        files = mjs['files'];
        metricsLM = DateTime.now().millisecondsSinceEpoch;
        if (files > 200) {
          Log('mm_service:149',
              'Warning, a large number of opened files, $files/256: $js');
        }
      }
    });
  }

  Future<void> init(String passphrase) async {
    await mmSe.runBin();
    metrics();

    jobService.install('updateOrdersAndSwaps', 3.14, (j) async {
      if (!mmSe.running) return;
      await updateOrdersAndSwaps();
    });

    jobService.install('updateMm2VersionInfo', 3.14, (j) async {
      if (!mmSe.running) return;
      if (mmVersion == null && mmDate == null) {
        await initializeMmVersion();
      }
    });
  }

  void initUsername(String passphrase) {
    final List<int> bytes = utf8.encode(passphrase); // data being hashed
    userpass = sha256.convert(bytes).toString();
  }

  String get filesPath => applicationDocumentsDirectorySync == null
      ? null
      : applicationDocumentsDirectorySync.path + '/';

  /// Returns a log file matching the present [now] time.
  FileAndSink currentLog({DateTime now}) {
    // Time can fluctuate back and forth due to time syncronization and such.
    // Hence we're using a map that allows us to direct the log entries
    // to a log file precisely matching the `now` time,
    // even if it happens to jump a bit into the past.
    // This in turn allows us to make the log lines shorter
    // by only mentioning the current time (and not date) in a line.
    now ??= DateTime.now();
    final ymd = '${now.year}'
        '-${Log.twoDigits(now.month)}'
        '-${Log.twoDigits(now.day)}';
    final log = _logs[ymd];
    if (log != null) return log;

    if (_logs.length > 2) _logs.clear(); // Close day-before-yesterday logs.

    // Remove old logs.

    final unusedLog = File('${filesPath}log.txt');
    if (unusedLog.existsSync()) unusedLog.deleteSync();

    final unusedLogDate = File('${filesPath}logDate.txt');
    if (unusedLogDate.existsSync()) unusedLogDate.deleteSync();

    final gz = File('${filesPath}dex.log.gz'); // _shareFile
    if (gz.existsSync()) gz.deleteSync();

    final files = Directory(filesPath);
    final logName = RegExp(r'^(\d{4})-(\d{2})-(\d{2})\.log$');
    final List<File> unlink = [];
    for (FileSystemEntity en in files.listSync()) {
      final name = path.basename(en.path);
      final mat = logName.firstMatch(name);
      if (mat == null) continue;
      if (en.statSync().type != FileSystemEntityType.file) continue;
      final int year = int.parse(mat[1]);
      final int month = int.parse(mat[2]);
      final int day = int.parse(mat[3]);
      final enDate = DateTime(year, month, day);
      if (enDate.isAfter(now)) continue;
      final int delta = now.difference(enDate).inDays;
      if (delta > 3) unlink.add(en);
    }
    for (File en in unlink) en.deleteSync();

    // Create and open the log.

    final file = File('$filesPath$ymd.log');
    if (!file.existsSync()) {
      file.createSync();
      file.writeAsStringSync('${DateTime.now()}');
    }

    final sink = file.openWrite(mode: FileMode.append);
    final ret = FileAndSink(file, sink);
    _logs[ymd] = ret;
    return ret;
  }

  Future<void> runBin() async {
    final String passphrase = await EncryptionTool().read('passphrase');
    initUsername(passphrase);
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String os = Platform.isAndroid ? 'Android' : 'iOS';
    gui = 'atomicDEX ${packageInfo.version} $os';
    if (Platform.isAndroid) {
      final buildTime = await nativeC.invokeMethod<int>('BUILD_TIME');
      gui += '; BT=${buildTime ~/ 1000}';
    }
    final String startParam = configMm2ToJson(ConfigMm2(
        gui: gui,
        netid: netid,
        client: 1,
        userhome: filesPath,
        passphrase: passphrase,
        rpcPassword: userpass,
        coins: await readJsonCoinInit(),
        dbdir: filesPath));

    logC
        .receiveBroadcastStream()
        .listen(_onNativeLog, onError: _onNativeLogError);

    try {
      final int errorCode = await nativeC.invokeMethod<dynamic>(
          'start', <String, String>{'params': startParam}); //start mm2
      final Mm2Error error = mm2ErrorFrom(errorCode);
      if (error != Mm2Error.ok) {
        if (error == Mm2Error.already_runs) {
          Log('mm_service', '$error, restarting mm2');
          await stopmm2();
          await runBin();
        } else {
          throw Exception('Error on start mm2: $error');
        }
      }

      // check when mm2 is ready then load coins
      final int timerTmp = DateTime.now().millisecondsSinceEpoch;
      Timer.periodic(const Duration(seconds: 2), (_) {
        final int t1 = timerTmp + 20000;
        final int t2 = DateTime.now().millisecondsSinceEpoch;
        if (t1 <= t2) {
          _.cancel();
        }

        checkStatusMm2().then((int onValue) {
          final status = mm2StatusFrom(onValue);
          Log('mm_service:313', 'mm2_main_status: $status');
          if (status == Mm2Status.ready) {
            _running = true;
            _.cancel();
            initCoinsAndLoad();
            coinsBloc.startCheckBalance();
          }
        });
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> initializeMmVersion() async {
    final VersionMm2 versionmm2 =
        await MM.getVersionMM2(BaseService(method: 'version'));
    if (versionmm2 is VersionMm2 && versionmm2 != null) {
      mmVersion = versionmm2.result;
      mmDate = versionmm2.datetime;
      Log('mm_service:305]', 'mm2 version info updated');

      jobService.suspend('updateMm2VersionInfo');
    }
  }

  void log2file(String chunk, {DateTime now}) {
    if (chunk == null) return;
    if (!chunk.endsWith('\n')) chunk += '\n';

    now ??= DateTime.now();
    final log = currentLog(now: now);

    // There's a chance that during life cycle transitions log file descriptor will be closed on iOS.
    // The try-catch will hopefully help us detect this and reopen the file.
    IOSink s = log.sink;
    try {
      s.write(chunk);
    } catch (ex) {
      print(ex);
      log.sink = s = log.file.openWrite(mode: FileMode.append);
      s.write(chunk);
    }
  }

  /// Load fresh lists of orders and swaps from MM.
  Future<void> updateOrdersAndSwaps() async {
    await swapMonitor.update();
    await ordersBloc.updateOrdersSwaps();
  }

  /// Process a line of MM log.
  void _onLog(String chunk) {
    Log('mm_service:338', chunk);
  }

  void _onNativeLog(Object event) {
    _onLog(event);
  }

  void _onNativeLogError(Object error) {
    Log('mm_service:415', error);
  }

  Future<List<CoinInit>> readJsonCoinInit() async {
    try {
      return coinInitFromJson(
          await rootBundle.loadString('assets/coins_init_mm2.json'));
    } catch (e) {
      if (kDebugMode) {
        Log('mm_service', 'readJsonCoinInit] $e');
        printError('$e');
        printError('Try to run `\$sh fetch_coins.sh`.'
            ' See README.md for details.');
        SystemChannels.platform.invokeMethod<dynamic>('SystemNavigator.pop');
      }
      return <CoinInit>[];
    }
  }

  Future<void> initCoinsAndLoad() async {
    try {
      await coinsBloc.activateCoinKickStart();
      final active = await coinsBloc.electrumCoins();
      await coinsBloc.enableCoins(active);
      Log('mm_service:432', 'All coins activated');
      await coinsBloc.updateCoinBalances();
      Log('mm_service:434', 'loadCoin finished');
    } catch (e) {
      Log('mm_service', 'initCoinsAndLoad: $e');
    }
  }

  Future<int> checkStatusMm2() async {
    return await nativeC.invokeMethod('status');
  }

  Future<void> lsof() async {
    if (!Platform.isIOS) return; // Only implemented on iOS.
    final rc = await nativeC.invokeMethod<int>('lsof');
    if (rc != 0) throw Exception('!lsof: $rc');
  }

  Future<File> get _localFile async {
    return File('${filesPath}mm2');
  }

  Future<File> saveMmBin(List<int> data) async {
    final File file = await _localFile;
    return file.writeAsBytes(data);
  }

  Future<void> deleteMmBin() async {
    final File file = await _localFile;
    await file.delete();
  }

  Future<void> stopmm2() async {
    if (Platform.isIOS) {
      await _stopmm2Ios();
      Log('mm_service', 'stopmm2: done');
      return;
    }

    try {
      final BaseService baseService =
          BaseService(userpass: userpass, method: 'stop');
      await client.post(Uri.parse(url), body: baseServiceToJson(baseService));

      _running = false;
    } catch (e) {
      Log('mm_service', 'stopmm2: $e');
    }
  }

  Future<void> _stopmm2Ios() async {
    final int errorCode = await nativeC.invokeMethod<int>('stop');
    final Mm2StopError error = mm2StopErrorFrom(errorCode);
    Log('mm_service', 'stopmm2Ios: $error');

    await pauseUntil(() async => await _mm2status() == Mm2Status.not_running);
    _running = false;
  }

  Future<Mm2Status> _mm2status() async {
    return mm2StatusFrom(await checkStatusMm2());
  }

  Future<dynamic> handleWakeUp() async {
    if (!Platform.isIOS) return;
    if (!running) return;

    /// Wait until mm2 is up, in case it was restarted from Swift
    await pauseUntil(() async => await MM.isRpcUp());

    /// If [running], but enabled coins list is empty,
    /// it means that mm2 was restarted from Swift, and we
    /// should reenable active coins ones again
    if ((await MM.getEnabledCoins()).isEmpty) initCoinsAndLoad();
  }

  Future<List<Balance>> getAllBalances(bool forceUpdate) async {
    Log('mm_service', 'getAllBalances');
    final List<Coin> coins = await coinsBloc.electrumCoins();

    if (balances.isEmpty || forceUpdate || coins.length != balances.length) {
      final List<Future<Balance>> futureBalances = <Future<Balance>>[];

      for (Coin coin in coins) {
        futureBalances.add(MM.getBalance(GetBalance(coin: coin.abbr)));
      }
      return await Future.wait<Balance>(futureBalances);
    } else {
      return [];
    }
  }
}

class FileAndSink {
  FileAndSink(this.file, this.sink);
  File file;
  IOSink sink;
}

/// mm2_main error codes defined in "mm2_lib.rs".
enum Mm2Error {
  ok,
  already_runs,
  conf_is_null,
  conf_not_utf8,
  cant_thread,
  unknown,
}

/// mm2_stop error codes defined in "mm2_lib.rs".
enum Mm2StopError {
  ok,
  not_running,
  error_stopping,
  unknown,
}

/// mm2_main_status codes defined in "mm2_lib.rs".
enum Mm2Status {
  not_running,
  no_context,
  no_rpc,
  ready,
  unknown,
}

Mm2Error mm2ErrorFrom(int errorCode) {
  switch (errorCode) {
    case 0:
      return Mm2Error.ok;
    case 1:
      return Mm2Error.already_runs;
    case 2:
      return Mm2Error.conf_is_null;
    case 3:
      return Mm2Error.conf_not_utf8;
    case 5:
      return Mm2Error.cant_thread;
    default:
      return Mm2Error.unknown;
  }
}

Mm2StopError mm2StopErrorFrom(int errorCode) {
  switch (errorCode) {
    case 0:
      return Mm2StopError.ok;
    case 1:
      return Mm2StopError.not_running;
    case 2:
      return Mm2StopError.error_stopping;
  }
  return Mm2StopError.unknown;
}

Mm2Status mm2StatusFrom(int statusCode) {
  switch (statusCode) {
    case 0:
      return Mm2Status.not_running;
    case 1:
      return Mm2Status.no_context;
    case 2:
      return Mm2Status.no_rpc;
    case 3:
      return Mm2Status.ready;
    default:
      return Mm2Status.unknown;
  }
}
