import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class SwapBloc implements BlocBase {
  OrderCoin orderCoin;
  CoinBalance sellCoin;

  // Streams to handle the list coin
  StreamController<OrderCoin> _orderCoinController =
      StreamController<OrderCoin>.broadcast();
  Sink<OrderCoin> get _inOrderCoin => _orderCoinController.sink;
  Stream<OrderCoin> get outOrderCoin => _orderCoinController.stream;

  // Streams to handle the list coin
  StreamController<CoinBalance> _sellCoinController =
      StreamController<CoinBalance>.broadcast();
  Sink<CoinBalance> get _inSellCoin => _sellCoinController.sink;
  Stream<CoinBalance> get outSellCoin => _sellCoinController.stream;

  List<OrderCoin> orderCoins = new List<OrderCoin>();

  // Streams to handle the list coin
  StreamController<List<OrderCoin>> _listOrderCoinController =
      StreamController<List<OrderCoin>>.broadcast();
  Sink<List<OrderCoin>> get _inListOrderCoin => _listOrderCoinController.sink;
  Stream<List<OrderCoin>> get outListOrderCoin =>
      _listOrderCoinController.stream;


  
  @override
  void dispose() {
    _orderCoinController.close();
    _sellCoinController.close();
    _listOrderCoinController.close();
  }

  void updateBuyCoin(OrderCoin orderCoin) {
    this.orderCoin = orderCoin;
    _inOrderCoin.add(this.orderCoin);
  }

  void updateSellCoin(CoinBalance coinBalance) {
    sellCoin = coinBalance;
    _inSellCoin.add(sellCoin);
  }

  Future<void> getBuyCoins(Coin rel) async {
    orderCoins = new List<OrderCoin>();

    List<Coin> coins = await coinsBloc.readJsonCoin();
    List<Future<Orderbook>> futureOrderbook = new List<Future<Orderbook>>();

    coins.forEach((coin) {
      futureOrderbook.add(mm2.getOrderbook(coin, rel));
    });
    List<Orderbook> orderbooks = await Future.wait(futureOrderbook);

    orderbooks.forEach((orderbook) {
      coins.forEach((coin) {
        if (orderbook.base == coin.abbr) {
          double bestPrice = 0;
          double maxVolume = 0;
          int i = 0;
          orderbook.asks.forEach((ask) {
            print("ask" + ask.price.toString());
            if (i == 0) {
              maxVolume = ask.maxvolume;
              bestPrice = ask.price;
            } else if (ask.price < bestPrice) {
              maxVolume = ask.maxvolume;
              bestPrice = ask.price;
            }
            i++;
          });
          print("BEST PRICE" + bestPrice.toString());
          orderCoins.add(OrderCoin(
            coinRel: rel,
            coinBase: coin,
            orderbook: orderbook,
            maxVolume: maxVolume,
            bestPrice: bestPrice,
          ));
        }
      });
    });

    _inListOrderCoin.add(orderCoins);
    return;
  }

}

final swapBloc = SwapBloc();
