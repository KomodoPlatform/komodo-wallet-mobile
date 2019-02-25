import 'dart:async';
import 'dart:io';

import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class CoinsBloc implements BlocBase {
  List<CoinBalance> _coinBalance = new List<CoinBalance>();
  List<Balance> _balances = new List<Balance>();

  // Streams to handle the list coin
  StreamController<List<CoinBalance>> _coinsController =
      StreamController<List<CoinBalance>>.broadcast();
  Sink<List<CoinBalance>> get _inCoins => _coinsController.sink;
  Stream<List<CoinBalance>> get outCoins => _coinsController.stream;

  CoinsBloc() {
    // init();
    mm2.runBin();
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

  void updateBalanceForEachCoin() async {
    _balances = await mm2.getAllBalances();

    for (var coinBalance in _coinBalance) {
      for (var balance in _balances) {
        if (coinBalance.coin.abbr == balance.coin) {
          coinBalance.balance = balance;
        }
      }
    }

    _inCoins.add(_coinBalance);
  }
}

final coinsBloc = CoinsBloc();
