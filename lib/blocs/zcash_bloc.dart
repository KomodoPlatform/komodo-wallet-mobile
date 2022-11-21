import 'dart:async';

import 'package:http/http.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ZCashBloc implements BlocBase {
  // Streams to zcash params download progress
  final StreamController<int> _zcashProgressController =
      StreamController<int>.broadcast();

  List<Coin> coinsToActivate = [];
  List<int> tasksToCheck = [];

  Sink<int> get _inZcashProgress => _zcashProgressController.sink;
  Stream<int> get outZcashProgress => _zcashProgressController.stream;
  int totalDownloadSize = 0;

  @override
  void dispose() {
    _zcashProgressController.close();
  }

  List<Coin> removeZcashCoins(List<Coin> coins) {
    coinsToActivate =
        coins.where((element) => element?.protocol?.type == 'ZHTLC').toList();
    if (coinsToActivate.isNotEmpty) {
      // remove zcash-coins from the main coin list if exists
      coins.removeWhere((coin) => coinsToActivate.contains(coin));
      downloadZParams();
      return coins;
    } else {
      return coins;
    }
  }

  Future autoEnableZcashCoins() async {
    final List<Map<String, dynamic>> batch = [];

    final dir = await getApplicationDocumentsDirectory();
    String folder = Platform.isIOS ? '/ZcashParams/' : '/.zcash-params/';
    for (Coin coin in coinsToActivate) {
      final electrum = {
        'userpass': mmSe.userpass,
        'method': 'task::enable_z_coin::init',
        'mmrpc': '2.0',
        'params': {
          'ticker': coin.abbr,
          'activation_params': {
            'mode': {
              'rpc': 'Light',
              'rpc_data': {
                'electrum_servers': Coin.getServerList(coin.serverList),
                'light_wallet_d_servers': coin.lightWalletDServers
              }
            },
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
      final reply = replies[i];
      int id = reply['result']['task_id'];
      tasksToCheck.add(id);
      jobService.install(
        'checkPresentZcashEnabling$id',
        5,
        (j) async {
          await MM.getZcashActivationStatus({
            'userpass': mmSe.userpass,
            'method': 'init_z_coin_status',
            'mmrpc': '2.0',
            'params': {'task_id': id}
          });
        },
      );
    }
    tasksToCheck = tasksToCheck.toSet().toList();
  }

  Future<void> downloadZParams() async {
    final dir = await getApplicationDocumentsDirectory();
    String folder = Platform.isIOS ? '/ZcashParams/' : '/.zcash-params/';
    Directory zDir = Directory(dir.path + folder);
    if (zDir.existsSync()) {
      await autoEnableZcashCoins();
      return;
    } else {
      zDir.createSync();
    }

    final params = [
      'https://z.cash/downloads/sapling-spend.params',
      'https://z.cash/downloads/sapling-output.params',
    ];

    int _received = 0;
    for (var param in params) {
      final List<int> _bytes = [];

      StreamedResponse _response;
      _response = await Client().send(Request('GET', Uri.parse(param)));
      totalDownloadSize += _response.contentLength ?? 0;

      print(totalDownloadSize);
      _response.stream.listen((value) {
        _bytes.addAll(value);
        _received += value.length;
        _inZcashProgress.add(_received);
      }).onDone(() async {
        final file = File(zDir.path + param.split('/').last);
        if (!file.existsSync()) await file.create();
        await file.writeAsBytes(_bytes);
        await autoEnableZcashCoins();
      });
    }
  }
}

ZCashBloc zcashBloc = ZCashBloc();
