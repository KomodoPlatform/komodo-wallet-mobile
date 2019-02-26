import 'dart:async';

import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class CoinsBloc implements BlocBase {
  List<CoinBalance> _coinBalance = new List<CoinBalance>();

  // Streams to handle the list coin
  StreamController<List<CoinBalance>> _coinsController =
      StreamController<List<CoinBalance>>.broadcast();

  Sink<List<CoinBalance>> get _inCoins => _coinsController.sink;
  Stream<List<CoinBalance>> get outCoins => _coinsController.stream;

  CoinsBloc() {
    init();
  }

  void init() async {
    _coinBalance = await mm2.loadCoins(true);
    _inCoins.add(_coinBalance);
  }

  @override
  void dispose() {
    _coinsController?.close();
  }

  void resetCoinBalance() {
    _coinBalance.clear();
    _inCoins.add(_coinBalance);
  }

  void updateCoins(List<CoinBalance> coins) {
    _coinBalance = coins;
    print(_coinBalance.length);
    _inCoins.add(_coinBalance);
  }

  void updateBalanceForEachCoin(bool forceUpdate) async {
    _coinBalance = await mm2.loadCoins(forceUpdate);

    _inCoins.add(_coinBalance);
  }

}

final coinsBloc = CoinsBloc();
