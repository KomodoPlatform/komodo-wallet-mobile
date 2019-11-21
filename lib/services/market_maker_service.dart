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
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/base_service.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_init.dart';
import 'package:komodo_dex/model/config_mm2.dart';
import 'package:komodo_dex/model/get_balance.dart';
import 'package:komodo_dex/services/api_providers.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/database.dart';

class MarketMakerService {
  factory MarketMakerService() {
    return _singleton;
  }

  MarketMakerService._internal();

  static final MarketMakerService _singleton = MarketMakerService._internal();

  List<dynamic> balances = <dynamic>[];
  Process mm2Process;
  List<Coin> coins = <Coin>[];
  bool ismm2Running = false;
  String url = 'http://localhost:7783';
  String userpass = '';
  Stream<List<int>> streamSubscriptionStdout;
  String pubkey = '';
  String filesPath = '';
  IOSink sink;
  static MethodChannel platformmm2 = const MethodChannel('mm2');
  static const EventChannel eventChannel = EventChannel('streamLogMM2');
  final Client client = http.Client();
  File logFile;

  Future<void> init(String passphrase) async {
    if (Platform.isAndroid) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final ProcessResult checkmm2process = await Process.run(
          'ps', <String>['-p', prefs.getInt('mm2ProcessPID').toString()]);
      if (prefs.getInt('mm2ProcessPID') == null ||
          !checkmm2process.stdout
              .toString()
              .contains(prefs.getInt('mm2ProcessPID').toString())) {
        await MarketMakerService().runBin();
      } else {
        MarketMakerService().initUsername(passphrase);
        MarketMakerService().ismm2Running = true;
        await MarketMakerService().initCheckLogs();
        coinsBloc.currentCoinActivate(null);
        coinsBloc.loadCoin();
        coinsBloc.startCheckBalance();
      }
    } else {
      await MarketMakerService().runBin();
    }
  }

  Future<void> initMarketMaker() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    filesPath = directory.path + '/';

    if (Platform.isAndroid) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String newBuildNumber = packageInfo.buildNumber;

      try {
        final ProcessResult checkmm2 =
            await Process.run('ls', <String>['${filesPath}mm2']);
        final String currentBuildNumber = prefs.getString('version');

        if (checkmm2.stdout.toString().trim() != '${filesPath}mm2' ||
            currentBuildNumber == null ||
            currentBuildNumber.isEmpty ||
            currentBuildNumber != newBuildNumber) {
          await prefs.setString('version', newBuildNumber);
          await coinsBloc.resetCoinDefault();
          final ByteData resultmm2 = await rootBundle.load('assets/mm2');
          if (checkmm2.stdout.toString().trim() == '${filesPath}mm2') {
            await deletemm2File();
          }
          await writeData(resultmm2.buffer.asUint8List());
          await Process.run('chmod', <String>['544', '${filesPath}mm2']);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void initUsername(String passphrase) {
    final List<int> bytes = utf8.encode(passphrase); // data being hashed
    userpass = sha256.convert(bytes).toString();
  }

  Future<void> initCheckLogs() async {
    final File fileLog = File('${filesPath}mm.log');

    if (!fileLog.existsSync()) {
      await fileLog.create();
    }
    int offset = await fileLog.length();

    Timer.periodic(const Duration(seconds: 1), (_) {
      fileLog
          .openRead(offset)
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((String data) {
        if (data.contains('DEX stats API enabled at')) {
          ismm2Running = true;
          initCoinsAndLoad();
          coinsBloc.startCheckBalance();
        }
        onLogsmm2(data);
      }).onDone(() async {
        offset = await fileLog.length();
      });
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
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      try {
        await platformmm2.invokeMethod<dynamic>(
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
              ismm2Running = true;
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

  /// Process a line of MM log,
  /// triggering an update of the swap and order lists whenever such changes are detected in the log.
  void onLogsmm2(String log) {
    if (sink != null) {
      Log.println('', log);
      // AG: This currently relies on the information that can be freely changed by MM
      // or removed from the logs entirely (e.g. on debug and human-readable parts).
      // Should update it to rely on the log tags instead.
      if (log.contains('CONNECTED') ||
          log.contains('Entering the taker_swap_loop') ||
          log.contains('Received \'negotiation') ||
          log.contains('Got maker payment') ||
          log.contains('Sending \'taker-fee') ||
          log.contains('Sending \'taker-payment') ||
          log.contains('Finished')) {
        Future<dynamic>.delayed(const Duration(seconds: 1), () {
          swapHistoryBloc.updateSwaps(50, null).then((_) {
            ordersBloc.updateOrdersSwaps();
          });
        });
      }
    }
  }

  void _onEvent(Object event) {
    onLogsmm2(event);
  }

  void _onError(Object error) {
    print(error);
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

      coinsBloc.addMultiCoins(await coinsBloc.readJsonCoin()).then((_) {
        Log.println('', 'All coins activated');
        coinsBloc.loadCoin().then((_) {
          Log.println('', 'loadCoin finished');
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<int> checkStatusmm2() async {
    return await platformmm2.invokeMethod('status');
  }

  Future<void> lsof() async {
    return await platformmm2.invokeMethod('lsof');
  }

  Future<File> get _localFile async {
    return File('${filesPath}mm2');
  }

  Future<File> writeData(List<int> data) async {
    final File file = await _localFile;
    return file.writeAsBytes(data);
  }

  Future<void> deletemm2File() async {
    final File file = await _localFile;
    await file.delete();
  }

  Future<dynamic> stopmm2() async {
    ismm2Running = false;
    try {
      final BaseService baseService =
          BaseService(userpass: userpass, method: 'stop');
      final Response response =
          await http.post(url, body: baseServiceToJson(baseService));
      // await Future<dynamic>.delayed(const Duration(seconds: 1));

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
    return await DBProvider.db.getAllCoinElectrum(CoinEletrum.DEFAULT);
  }

  Future<List<dynamic>> getAllBalances(bool forceUpdate) async {
    final List<Coin> coins = await coinsBloc.readJsonCoin();

    if (balances.isEmpty || forceUpdate || coins.length != balances.length) {
      List<dynamic> balances = <dynamic>[];
      final List<Future<dynamic>> futureBalances = <Future<dynamic>>[];

      for (Coin coin in coins) {
        futureBalances.add(ApiProvider().getBalance(
            MarketMakerService().client, GetBalance(coin: coin.abbr)));
      }
      balances = await Future.wait<dynamic>(futureBalances);
      balances = balances;
      return balances;
    } else {
      return balances;
    }
  }

  Future<String> loadElectrumServersAsset() async {
    return coinToJson(
        await DBProvider.db.getAllCoinElectrum(CoinEletrum.CONFIG));
  }
}
