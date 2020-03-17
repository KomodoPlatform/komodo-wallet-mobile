import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show File, Platform, Process, ProcessResult;

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
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/database.dart';

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
  String pubkey = '';
  String filesPath = '';
  IOSink sink;

  /// Channel to native code.
  static MethodChannel nativeC = const MethodChannel('mm2');

  /// MM log streamed from iOS/Swift.
  static const EventChannel iosLogC = EventChannel('streamLogMM2');
  final Client client = http.Client();
  File logFile;

  /// Flips on temporarily when we see an indication of swap activity,
  /// possibly a change of swap status, in MM logs,
  /// triggering a Timer-based invocation of `updateOrdersAndSwaps`.
  String shouldUpdateOrdersAndSwaps;

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
        coinsBloc.loadCoin();
        coinsBloc.startCheckBalance();
      }
    } else {
      await mmSe.runBin();
    }

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

  Future<void> initMarketMaker() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    filesPath = directory.path + '/';

    if (Platform.isAndroid) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      try {
        final ls = await Process.run('ls', <String>['${filesPath}mm2']);
        final lsMatch = ls.stdout.toString().trim() == '${filesPath}mm2';

        final mm2hash = prefs.getString('mm2_hash') ?? '';

        Log('mm_service:114', 'Loading the mm2 asset…');
        final ByteData assetsMm2 = await rootBundle.load('assets/mm2');
        Log('mm_service:116', 'Calculating the mm2 asset hash…');
        final assHash = sha1.convert(assetsMm2.buffer.asUint8List()).toString();
        final hashMatch = mm2hash.isNotEmpty && mm2hash == assHash;
        Log('mm_service:119', 'Hash matches? $hashMatch');

        if (!lsMatch || !hashMatch) {
          await coinsBloc.resetCoinDefault();
          if (lsMatch) await deleteMmBin();
          await saveMmBin(assetsMm2.buffer.asUint8List());
          await prefs.setString('mm2_hash', mm2hash);
          await Process.run('chmod', <String>['0544', '${filesPath}mm2']);
        }
      } catch (e) {
        Log('mm_service:129', e);
      }
    }
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

  Future<void> initLogSink() async {
    final File dateFile = File('${filesPath}logDate.txt');
    logFile = File('${filesPath}log.txt');

    if ((logFile.existsSync() && logFile.lengthSync() > 7900000) ||
        (dateFile.existsSync() &&
            (DateTime.now().isAfter(DateTime.parse(dateFile.readAsStringSync())
                .add(const Duration(days: 2)))))) {
      await logFile.delete();
      logFile.create();
      await dateFile.delete();
      dateFile.createSync();
      dateFile.writeAsString('${DateTime.now()}');
    } else if (!dateFile.existsSync()) {
      dateFile.createSync();
      dateFile.writeAsString('${DateTime.now()}');
    } else if (!logFile.existsSync()) {
      logFile.create();
    }
    sink = logFile.openWrite(mode: FileMode.append);
  }

  void openLogSink() {
    if (logFile != null && sink == null) {
      sink = logFile.openWrite(mode: FileMode.append);
    }
  }

  void closeLogSink() {
    if (sink != null) {
      sink.close();
      sink = null;
    }
  }

  Future<void> runBin() async {
    final String passphrase = await EncryptionTool().read('passphrase');
    initUsername(passphrase);
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String os = Platform.isAndroid ? 'Android' : 'iOS';
    final String startParam = configMm2ToJson(ConfigMm2(
        gui: 'atomicDEX ${packageInfo.version} $os',
        netid: 9999,
        client: 1,
        userhome: filesPath,
        passphrase: passphrase,
        rpcPassword: userpass,
        coins: await readJsonCoinInit(),
        dbdir: filesPath));

    await initLogSink();

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
      iosLogC
          .receiveBroadcastStream()
          .listen(_onIosLogEvent, onError: _onIosLogError);
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
            print('STATUS MM2: ' + onValue.toString());
            if (onValue == 3) {
              _running = true;
              _.cancel();
              print('CANCEL TIMER');
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

  void logIntoFile(String log) {
    if (sink != null) {
      sink.write(log + '\n');
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
    if (sink != null) {
      Log('mm_service:307', chunk);
      final reasons = _lookupReasons(chunk);
      // TBD: Use the obtained swap UUIDs for targeted swap updates.
      if (reasons.isNotEmpty) shouldUpdateOrdersAndSwaps = reasons.first.sample;
    }
  }

  /// Checks a [chunk] of MM log to see if there's a reason to reload swap status.
  List<_UpdReason> _lookupReasons(String chunk) {
    final List<_UpdReason> reasons = [];
    final sending = RegExp(
        r'\d+ \d{2}:\d{2}:\d{2}, \w+:\d+] Sending \W[\w-]+@([\w-]+)\W \(\d+ bytes');
    for (RegExpMatch mat in sending.allMatches(chunk)) {
      //Log('mm_service:320', 'uuid: ${mat.group(1)}; sample: ${mat.group(0)}');
      reasons.add(_UpdReason(sample: mat.group(0), uuid: mat.group(1)));
    }

    // | (0:46) [swap uuid=9d590dcf-98b8-4990-9d3d-ab3b81af9e41] Started...
    // | (1:18) [swap uuid=9d590dcf-98b8-4990-9d3d-ab3b81af9e41] Negotiated...
    final dashboard = RegExp(r'\| \(\d+:\d+\) \[swap uuid=([\w-]+)\] \w.*');
    for (RegExpMatch mat in dashboard.allMatches(chunk)) {
      //Log('mm_service:328', 'uuid: ${mat.group(1)}; sample: ${mat.group(0)}');
      reasons.add(_UpdReason(sample: mat.group(0), uuid: mat.group(1)));
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

  void _onIosLogEvent(Object event) {
    _onLog(event);
  }

  void _onIosLogError(Object error) {
    Log('mm_service:351', error);
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

      coinsBloc.enableCoins(await coinsBloc.electrumCoins()).then((_) {
        Log('mm_service:368', 'All coins activated');
        coinsBloc.loadCoin().then((_) {
          Log('mm_service:370', 'loadCoin finished');
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<int> checkStatusmm2() async {
    return await nativeC.invokeMethod('status');
  }

  Future<void> lsof() async {
    return await nativeC.invokeMethod('lsof');
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

  Future<List<Coin>> loadJsonCoins(String loadFile) async {
    final String jsonString = loadFile;
    final Iterable<dynamic> l = json.decode(jsonString);
    final List<Coin> coins =
        l.map((dynamic model) => Coin.fromJson(model)).toList();
    return coins;
  }

  Future<List<Coin>> loadJsonCoinsDefault() async {
    return await DBProvider.db.electrumCoins(CoinEletrum.DEFAULT);
  }

  Future<List<Balance>> getAllBalances(bool forceUpdate) async {
    Log('mm_service:430', 'getAllBalances');
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

  Future<String> loadElectrumServersAsset() async {
    return coinToJson(await DBProvider.db.electrumCoins(CoinEletrum.CONFIG));
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
