import 'coin.dart';

class MmTendermintTokenEnable {
  MmTendermintTokenEnable({
    required this.userpass,
    this.method = 'enable_tendermint_token',
    required this.coin,
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
          'activation_params': {
            'tx_history': true,
          },
          'tx_history': true,
        }
      };
}

class MmTendermintAssetEnable {
  MmTendermintAssetEnable({
    required this.userpass,
    this.method = 'enable_tendermint_with_assets',
    required this.coin,
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
          'rpc_urls': coin.serverList?.map((e) => e.url).toList(),
          'ticker': coin.abbr,
          'tx_history': true,
        }
      };
}
