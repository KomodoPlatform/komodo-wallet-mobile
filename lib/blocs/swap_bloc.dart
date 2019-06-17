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
  bool enabledReceiveField;
  bool enabledSellField;

  StreamController<OrderCoin> _orderCoinController =
      StreamController<OrderCoin>.broadcast();
  Sink<OrderCoin> get _inOrderCoin => _orderCoinController.sink;
  Stream<OrderCoin> get outOrderCoin => _orderCoinController.stream;

  Coin receiveCoin;
  StreamController<Coin> _receiveCoinController =
      StreamController<Coin>.broadcast();
  Sink<Coin> get _inReceiveCoin => _receiveCoinController.sink;
  Stream<Coin> get outReceiveCoin => _receiveCoinController.stream;

  StreamController<CoinBalance> _sellCoinController =
      StreamController<CoinBalance>.broadcast();
  Sink<CoinBalance> get _inSellCoin => _sellCoinController.sink;
  Stream<CoinBalance> get outSellCoin => _sellCoinController.stream;

  List<OrderCoin> orderCoins = new List<OrderCoin>();

  StreamController<List<OrderCoin>> _listOrderCoinController =
      StreamController<List<OrderCoin>>.broadcast();
  Sink<List<OrderCoin>> get _inListOrderCoin => _listOrderCoinController.sink;
  Stream<List<OrderCoin>> get outListOrderCoin =>
      _listOrderCoinController.stream;

  bool focusTextField = false;

  StreamController<bool> _focusTextFieldController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inFocusTextField => _focusTextFieldController.sink;
  Stream<bool> get outFocusTextField => _focusTextFieldController.stream;

  double amountReceive;

  StreamController<double> _amountReceiveController =
      StreamController<double>.broadcast();
  Sink<double> get _inAmountReceiveCoin => _amountReceiveController.sink;
  Stream<double> get outAmountReceive => _amountReceiveController.stream;


  bool isTimeOut = false;

  StreamController<bool> _isTimeOutController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsTimeOut => _isTimeOutController.sink;
  Stream<bool> get outIsTimeOut => _isTimeOutController.stream;

  int indexTab = 0;
  StreamController<int> _indexTabController =
  StreamController<int>.broadcast();
  Sink<int> get _inIndexTab => _indexTabController.sink;
  Stream<int> get outIndexTab => _indexTabController.stream;

  @override
  void dispose() {
    _orderCoinController.close();
    _sellCoinController.close();
    _listOrderCoinController.close();
    _focusTextFieldController.close();
    _receiveCoinController.close();
    _amountReceiveController.close();
    _indexTabController.close();
  }

  void setIndexTabDex(int index) {
    this.indexTab = index;
    _indexTabController.add(this.indexTab);
  }

  void updateBuyCoin(OrderCoin orderCoin) {
    this.orderCoin = orderCoin;
    _inOrderCoin.add(this.orderCoin);
  }

  void updateReceiveCoin(Coin receiveCoin) {
    this.receiveCoin = receiveCoin;
    _inReceiveCoin.add(this.receiveCoin);
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

  String getExchangeRate() {
    if (swapBloc.orderCoin != null) {
      return '1 ${swapBloc.orderCoin.coinBase.abbr} = ${swapBloc.orderCoin.bestPrice.toStringAsFixed(8)} ${swapBloc.orderCoin.coinRel.abbr}';
    } else {
      return "";
    }
  }

  String getExchangeRateUSD() {
    if (swapBloc.orderCoin != null && this.sellCoin.priceForOne != null) {
      String res = (this.sellCoin.priceForOne * swapBloc.orderCoin.bestPrice)
          .toStringAsFixed(2);
      return '($res USD)';
    } else {
      return "";
    }
  }

  void setFocusTextField(bool focus) {
    this.focusTextField = focus;
    _inFocusTextField.add(this.focusTextField);
  }

  Future<double> setReceiveAmount(Coin coin, String amountSell) async {
    Orderbook orderbook = await mm2.getOrderbook(sellCoin.coin, coin);
    double bestPrice = 0;
    double maxVolume = 0;
    int i = 0;
    orderbook.asks.forEach((ask) {
      if (ask.address != swapBloc.sellCoin.balance.address) {
        if (i == 0) {
          maxVolume = ask.maxvolume;
          bestPrice = ask.price;
        } else if (ask.price < bestPrice) {
          maxVolume = ask.maxvolume;
          bestPrice = ask.price;
        }
        i++;
      }
    });
    print("BEST PRICE" + bestPrice.toString());
    this.orderCoin = OrderCoin(
      coinRel: sellCoin.coin,
      coinBase: coin,
      orderbook: orderbook,
      maxVolume: maxVolume,
      bestPrice: bestPrice,
    );
    _inOrderCoin.add(this.orderCoin);

    this.amountReceive = double.parse(this.orderCoin.getBuyAmount(double.parse(amountSell.replaceAll(",", "."))));
    _inAmountReceiveCoin.add(this.amountReceive);
    return this.amountReceive;
  }

  void setTimeout(bool time) {
    this.isTimeOut = time;
    _inIsTimeOut.add(this.isTimeOut);
  }
}

final swapBloc = SwapBloc();
