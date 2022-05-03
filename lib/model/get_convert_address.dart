import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';

class GetConvertAddress {
  GetConvertAddress({
    this.method = 'convertaddress',
    this.userpass,
    this.from,
    this.coin,
  });

  String method;
  String userpass;
  String from;
  String coin;

  Map<String, dynamic> toJson() {
    final CoinBalance coinBalance = coinsBloc.getBalanceByAbbr(coin);
    final String coinType = coinBalance.coin.type;
    final bool isERC = appConfig.coinTypes.contains(coinType);

    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'from': from,
      'coin': coin,
      'to_address_format': {
        'format': isERC ? 'mixedcase' : 'cashaddress',
        if (coin == 'BCH') 'network': 'bitcoincash',
      }
    };
  }
}
