import 'dart:async';

import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class CoinJsonBloc implements BlocBase{
  Coin baseCoin = Coin(
    name: "pizza",
    abbr: "PIZZA",
  );
  Coin relCoin = Coin(
    name: "beer",
    abbr: "BEER",
  );

  // Streams to handle the list coin
  StreamController<Coin> _baseCoinController =
      StreamController<Coin>.broadcast();
  Sink<Coin> get _inBaseCoin => _baseCoinController.sink; 
  Stream<Coin> get outBaseCoin => _baseCoinController.stream;

  // Streams to handle the list coin
  StreamController<Coin> _relCoinController =
      StreamController<Coin>.broadcast();
  Sink<Coin> get _inRelCoin => _relCoinController.sink; 
  Stream<Coin> get outRelCoin => _relCoinController.stream;

  @override
  void dispose() {
    _baseCoinController.close();
  }

  void updateBaseCoin(Coin coin){
    baseCoin = coin;
    _inBaseCoin.add(baseCoin);
  }

  void updateRelCoin(Coin coin) {
    relCoin = coin;
    _inRelCoin.add(relCoin);
  }

}