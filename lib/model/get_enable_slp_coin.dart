import 'coin.dart';

class MmParentSlpEnable {
  MmParentSlpEnable({
    this.userpass,
    this.method = 'enable_bch_with_tokens',
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
          'allow_slp_unsafe_conf': false,
          'bchd_urls': coin.bchdUrls,
          'mode': {
            'rpc': 'Electrum',
            'rpc_data': {'servers': Coin.getServerList(coin.serverList)}
          },
          'tx_history': true,
          'slp_tokens_requests': [],
        }
      };
}

class MmChildSlpEnable {
  MmChildSlpEnable({
    this.userpass,
    this.method = 'enable_slp',
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
          'activation_params': {
            'required_confirmations': coin.requiredConfirmations
          },
        }
      };
}
