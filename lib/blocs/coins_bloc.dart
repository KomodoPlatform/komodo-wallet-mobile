import 'dart:async';

import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class CoinsBloc implements BlocBase {
  List<CoinBalance> _coinBalance;
  List<Balance> _balances;
  
  // Streams to handle the list coin
  StreamController<List<CoinBalance>> _coinsController =
      StreamController<List<CoinBalance>>.broadcast();
  Sink<List<CoinBalance>> get _inCoins => _coinsController.sink; 
  Stream<List<CoinBalance>> get outCoins => _coinsController.stream;

  CoinsBloc(){
    init();
  }

  void init() async {
    _coinBalance = await mm2.loadCoins();
    _inCoins.add(_coinBalance);
  }

  @override
  void dispose() {
    _coinsController?.close();
  }

  void updateCoins(List<CoinBalance> coins) {
    _coinBalance = coins;
    _inCoins.add(_coinBalance);
  }

  void updateBalanceForEachCoin() async{
    _balances = await mm2.getAllBalances();

    _coinBalance.forEach((coinBalance){
      _balances.forEach((balance){
        if (coinBalance.coin.abbr == balance.coin) {
          coinBalance.balance = balance;
        }
      });
    });
    _inCoins.add(_coinBalance);
  }
}