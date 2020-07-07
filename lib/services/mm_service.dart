import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show File, Platform, Process, ProcessResult;

import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart'
    show ByteData, EventChannel, MethodChannel, rootBundle;
import 'package:flutter/services.dart' show ByteData, rootBundle;
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
import 'package:komodo_dex/services/music_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Our p2p ID, 64 bytes version
  /// (There is also a 66 bytes version, 64 bytes version is a tail of it)
  String pubkey = '';

  /// Our name and version
  String gui;

  /// We're using the netid of 9999 currently
  /// But it's possible in theory to connect the UI to MM running on a different netid
  /// Might want to check if we're running under the standard netid before we gossip
  int netid;

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
  final Client client = http.Client();

  /// Maps a $year-$month-$day date to the corresponding log file.
  /// The current date time can fluctuate (due to time correction services, for instance)
  /// so the map helps us with always picking the file that corresponds to the actual date.
  final Map<String, FileAndSink> _logs = {};

  /// Flips on temporarily when we see an indication of swap activity,
  /// possibly a change of swap status, in MM logs,
  /// triggering a Timer-based invocation of `updateOrdersAndSwaps`.
  String shouldUpdateOrdersAndSwaps;

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
    if (Platform.isAndroid) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final ProcessResult checkmm2process = await Process.run(
          'ps', <String>['-p', prefs.getInt('mm2ProcessPID').toString()]);
      if (prefs.getInt('mm2ProcessPID') == null ||
          !checkmm2process.stdout
              .toString()
              .contains(prefs.getInt('mm2ProcessPID').toString())) {
        await mmSe.runBin();
      } else {
        mmSe.initUsername(passphrase);
        mmSe._running = true;
        await mmSe.initCheckLogs();
        coinsBloc.currentCoinActivate(null);
        coinsBloc.updateCoinBalances();
        coinsBloc.startCheckBalance();
      }
    } else {
      await mmSe.runBin();
    }

    metrics();

    jobService.install('updateOrdersAndSwaps', 3.14, (j) async {
      final String reason = shouldUpdateOrdersAndSwaps;
      shouldUpdateOrdersAndSwaps = null;
      if (reason != null) {
        await updateOrdersAndSwaps(reason);
      } else if (musicService.recommendsPeriodicUpdates) {
        await syncSwaps.update('musicService');
      }
    });
  }

  /// Updates the executable copy of the Market Maker binary.
  Future<void> updateMmBinary(Function uiLog) async {
    uiLog('Loading preferences…');

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final ls = await Process.run('ls', <String>['${filesPath}mm2']);

    // True if the "mm2" file is there AND if we can invoke shell commands, such as "ls".
    final lsMatch = ls.stdout.toString().trim() == '${filesPath}mm2';

    // Sanity check: native code must reply us with 'pong'.
    final String pong = await nativeC.invokeMethod<String>('ping');
    if (pong != 'pong') throw Exception('No pong');

    final buildTime = await nativeC.invokeMethod<int>('BUILD_TIME');
    Log('mm_service:207', 'BUILD_TIME: $buildTime');
    if (buildTime <= 0) throw Exception('No BUILD_TIME');
    final ms = DateTime.now().millisecondsSinceEpoch;
    if (ms <= buildTime) Log('mm_service:210', 'BUILD_TIME in the future!');

    final lastHash = prefs.getString('mm2.lastHash') ?? '';
    final lastCheck = prefs.getInt('mm2.lastCheck') ?? 0;
    if (ms <= lastCheck) Log('mm_service:214', 'lastCheck in the future!');

    // If there's a copy of mm2 binary and we've checked it recently then we're done.
    if (lsMatch && buildTime < lastCheck) return;

    // NB: Unpacking `mm2` from the assets archive is a CPU-intensive operation
    // and locks the UI thread. Spawning a second Dart isolate is not an option
    // because it would not have `rootBundle` access. If we need UI to stay
    // responsive then we can move the MM update into the Java native code.

    uiLog('Loading assets/mm2…');
    Log('mm_service:225', 'Loading assets/mm2…');
    await sleepMs(22); // Gives UI a chance to update before we CPU-lock
    final ByteData mm2bytes = await rootBundle.load('assets/mm2');

    uiLog('Calculating mm2 hash…');
    Log('mm_service:230', 'Calculating assets/mm2 hash…');
    await sleepMs(22); // Gives UI a chance to update before we CPU-lock
    // AG: On my device it takes 7.7 seconds to calculate SHA1, 4.3 seconds to calculate MD5.
    final md5h = md5.convert(mm2bytes.buffer.asUint8List()).toString();
    if (md5h == lastHash) {
      Log('mm_service:235', 'MM matches the assets/ hash, skipping update');
      await prefs.setInt('mm2.lastCheck', ms);
      return;
    }

    uiLog('Updating MM…');
    Log('mm_service:241', 'Updating MM…');
    await sleepMs(22); // Gives UI a chance to update before we CPU-lock
    if (lsMatch) await deleteMmBin();
    await saveMmBin(mm2bytes.buffer.asUint8List());
    await Process.run('chmod', <String>['0544', '${filesPath}mm2']);
    await prefs.setString('mm2.lastHash', md5h);
    await prefs.setInt('mm2.lastCheck', ms);
  }

  void initUsername(String passphrase) {
    final List<int> bytes = utf8.encode(passphrase); // data being hashed
    userpass = sha256.convert(bytes).toString();
  }

  Future<void> initCheckLogs() async {
    final File fileLog = File('${filesPath}mm.log');

    if (!fileLog.existsSync()) await fileLog.create();
    int offset = fileLog.lengthSync();

    jobService.install('tail MM log', 1, (j) async {
      final Stream<String> stream = fileLog
          .openRead(offset)
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (String chunk in stream) {
        if (chunk.contains('DEX stats API enabled at')) {
          _running = true;
          initCoinsAndLoad();
          coinsBloc.startCheckBalance();
        }
        _onLog(chunk);
      }
      offset = fileLog.lengthSync();
      if (offset > 1024 * 1024) {
        // #653: Truncate the MM log buffer which is used presently on Android.
        // `_onLog` copies chunks into the "log.txt"
        // hence we can just truncate the "mm.log" without separately copying it.
        final IOSink truncSink = fileLog.openWrite();
        await truncSink.close();
      }
    });
  }

  Future<void> waitUntilMM2isStop() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('mm2ProcessPID') != null) {
      for (int i = 0; i < 100; i++) {
        final ProcessResult checkmm2process = await Process.run(
            'ps', <String>['-p', prefs.getInt('mm2ProcessPID').toString()]);
        if (!checkmm2process.stdout
            .toString()
            .contains(prefs.getInt('mm2ProcessPID').toString())) {
          break;
        }
        await Future<dynamic>.delayed(const Duration(milliseconds: 500));
      }
    }
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
        netid: 9999,
        client: 1,
        userhome: filesPath,
        passphrase: passphrase,
        rpcPassword: userpass,
        coins: await readJsonCoinInit(),
        dbdir: filesPath));

    logC
        .receiveBroadcastStream()
        .listen(_onNativeLog, onError: _onNativeLogError);

    if (Platform.isAndroid) {
      await stopmm2();
      await waitUntilMM2isStop();

      await File('${filesPath}MM2.json').writeAsString(startParam);

      try {
        await initCheckLogs();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        Process.run('./mm2', <String>[],
                environment: <String, String>{'MM_LOG': '${filesPath}mm.log'},
                workingDirectory: filesPath)
            .then((ProcessResult onValue) {
          prefs.setInt('mm2ProcessPID', onValue.pid);
        });
      } catch (e) {
        print(e);
        rethrow;
      }
    } else if (Platform.isIOS) {
      try {
        await nativeC.invokeMethod<dynamic>(
            'start', <String, String>{'params': startParam}); //start mm2

        // check when mm2 is ready then load coins
        final int timerTmp = DateTime.now().millisecondsSinceEpoch;
        Timer.periodic(const Duration(seconds: 2), (_) {
          final int t1 = timerTmp + 20000;
          final int t2 = DateTime.now().millisecondsSinceEpoch;
          if (t1 <= t2) {
            _.cancel();
          }

          checkStatusmm2().then((int onValue) {
            Log('mm_service:423', 'mm2_main_status: $onValue');
            if (onValue == 3) {
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
      print(ex); // AG: We should *gossip* this exception in the future.
      log.sink = s = log.file.openWrite(mode: FileMode.append);
      s.write(chunk);
    }
  }

  /// Load fresh lists of orders and swaps from MM.
  Future<void> updateOrdersAndSwaps(String reason) async {
    await syncSwaps.update(reason);
    await ordersBloc.updateOrdersSwaps();
  }

  /// Process a line of MM log,
  /// triggering an update of the swap and order lists whenever such changes are detected in the log.
  void _onLog(String chunk) {
    Log('mm_service:467', chunk);

    final pkr =
        RegExp(r'initialize] netid (\d+) public key (\w+) preferred port');
    final pkm = pkr.firstMatch(chunk);
    if (pkm != null) {
      netid = int.parse(pkm[1]);
      pubkey = pkm[2];
    }

    final mvr = RegExp(r'lp_init] version: (\w+) DT (\d{4}-\d{2}-\d{2})T\d{2}');
    final mvm = mvr.firstMatch(chunk);
    if (mvm != null) {
      mmVersion = mvm[1];
      mmDate = mvm[2];
    }

    final reasons = _lookupReasons(chunk);
    // TBD: Use the obtained swap UUIDs for targeted swap updates.
    if (reasons.isNotEmpty) shouldUpdateOrdersAndSwaps = reasons.first.sample;
  }

  /// Checks a [chunk] of MM log to see if there's a reason to reload swap status.
  List<_UpdReason> _lookupReasons(String chunk) {
    final List<_UpdReason> reasons = [];
    final sending = RegExp(
        r'\d+ \d{2}:\d{2}:\d{2}, \w+:\d+] Sending \W[\w-]+@([\w-]+)\W \(\d+ bytes');
    for (RegExpMatch mat in sending.allMatches(chunk)) {
      //Log('mm_service:495', 'uuid: ${mat.group(1)}; sample: ${mat.group(0)}');
      reasons.add(_UpdReason(sample: mat[0], uuid: mat[1]));
    }

    // | (0:46) [swap uuid=9d590dcf-98b8-4990-9d3d-ab3b81af9e41] Started...
    // | (1:18) [swap uuid=9d590dcf-98b8-4990-9d3d-ab3b81af9e41] Negotiated...
    final dashboard = RegExp(r'\| \(\d+:\d+\) \[swap uuid=([\w-]+)\] \w.*');
    for (RegExpMatch mat in dashboard.allMatches(chunk)) {
      //Log('mm_service:503', 'uuid: ${mat.group(1)}; sample: ${mat.group(0)}');
      reasons.add(_UpdReason(sample: mat[0], uuid: mat[1]));
    }

    const samples = [
      'CONNECTED',
      '[dht-boot]',
      'Entering the taker_swap_loop',
      'Finished'
    ];
    for (String sample in samples) {
      if (chunk.contains(sample)) {
        reasons.add(_UpdReason(sample: 'MM log: $sample'));
      }
    }
    return reasons;
  }

  void _onNativeLog(Object event) {
    _onLog(event);
  }

  void _onNativeLogError(Object error) {
    Log('mm_service:526', error);
  }

  Future<List<CoinInit>> readJsonCoinInit() async {
    try {
      return coinInitFromJson(
          await rootBundle.loadString('assets/coins_init_mm2.json'));
    } catch (e) {
      return <CoinInit>[];
    }
  }

  Future<void> initCoinsAndLoad() async {
    try {
      await coinsBloc.activateCoinKickStart();
      final active = await coinsBloc.electrumCoins();
      await coinsBloc.enableCoins(active);
      Log('mm_service:543', 'All coins activated');
      await coinsBloc.updateCoinBalances();
      Log('mm_service:545', 'loadCoin finished');
    } catch (e) {
      print(e);
    }
  }

  Future<int> checkStatusmm2() async {
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

  Future<dynamic> stopmm2() async {
    _running = false;
    try {
      final BaseService baseService =
          BaseService(userpass: userpass, method: 'stop');
      final Response response =
          await http.post(url, body: baseServiceToJson(baseService));
      // await Future<dynamic>.delayed(const Duration(seconds: 1));

      _running = false;
      return baseServiceFromJson(response.body);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Balance>> getAllBalances(bool forceUpdate) async {
    Log('mm_service:593', 'getAllBalances');
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

/// Reason for updating the list of orders and swaps.
class _UpdReason {
  _UpdReason({this.sample, this.uuid});

  /// MM log sample that was the reason for update.
  String sample;

  /// Swap UUID that ought to be updated.
  String uuid;
}

class FileAndSink {
  FileAndSink(this.file, this.sink);
  File file;
  IOSink sink;
}
