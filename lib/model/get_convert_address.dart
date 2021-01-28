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
    final bool isERC = coinBalance.coin.type == 'erc';

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
