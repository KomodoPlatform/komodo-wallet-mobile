import 'coin.dart';

class MmTendermintTokenEnable {
  MmTendermintTokenEnable({
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

class MmTendermintAssetEnable {
  MmTendermintAssetEnable({
    this.userpass,
    this.method = 'enable_tendermint_with_assets',
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
          'tokens_params': [],
          'rpc_urls': coin.serverList.map((e) => e.url).toList(),
          'ticker': coin.abbr,
        }
      };
}
