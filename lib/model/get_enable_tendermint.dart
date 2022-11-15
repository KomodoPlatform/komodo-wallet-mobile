import 'coin.dart';
import 'get_active_coin.dart';

class MmIrisEnable {
  MmIrisEnable({
    this.userpass,
    this.method = 'enable_tendermint_token',
    this.coin,
  });

  Coin coin;
  String userpass;
  String method;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mmrpc': '2.0',
        'userpass': userpass,
        'method': method,
        'params': {
          'ticker': coin.abbr,
          'activation_params': {},
        }
      };
}

class MmCosmosEnable {
  MmCosmosEnable({
    this.userpass,
    this.method = 'enable_tendermint_with_assets',
    this.coin,
    this.servers,
  });

  Coin coin;
  String userpass;
  String method;
  List<Server> servers;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mmrpc': '2.0',
        'userpass': userpass,
        'method': method,
        'params': {
          'tokens_params': [],
          'avg_block_time': coin.avgBlockTime,
          'rpc_urls': servers.map((e) => e.url).toList(),
          'ticker': coin.abbr,
        }
      };
}
