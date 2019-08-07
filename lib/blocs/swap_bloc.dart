import 'dart:async';

import 'package:decimal/decimal.dart';
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

  final StreamController<OrderCoin> _orderCoinController =
      StreamController<OrderCoin>.broadcast();
  Sink<OrderCoin> get _inOrderCoin => _orderCoinController.sink;
  Stream<OrderCoin> get outOrderCoin => _orderCoinController.stream;

  Coin receiveCoin;
  final StreamController<Coin> _receiveCoinController =
      StreamController<Coin>.broadcast();
  Sink<Coin> get _inReceiveCoin => _receiveCoinController.sink;
  Stream<Coin> get outReceiveCoin => _receiveCoinController.stream;

  final StreamController<CoinBalance> _sellCoinController =
      StreamController<CoinBalance>.broadcast();
  Sink<CoinBalance> get _inSellCoin => _sellCoinController.sink;
  Stream<CoinBalance> get outSellCoin => _sellCoinController.stream;

  List<Orderbook> orderCoins = <Orderbook>[];

  final StreamController<List<Orderbook>> _listOrderCoinController =
      StreamController<List<Orderbook>>.broadcast();
  Sink<List<Orderbook>> get _inListOrderCoin => _listOrderCoinController.sink;
  Stream<List<Orderbook>> get outListOrderCoin =>
      _listOrderCoinController.stream;

  bool focusTextField = false;

  final StreamController<bool> _focusTextFieldController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inFocusTextField => _focusTextFieldController.sink;
  Stream<bool> get outFocusTextField => _focusTextFieldController.stream;

  double amountReceive;

  final StreamController<double> _amountReceiveController =
      StreamController<double>.broadcast();
  Sink<double> get _inAmountReceiveCoin => _amountReceiveController.sink;
  Stream<double> get outAmountReceive => _amountReceiveController.stream;

  bool isTimeOut = false;

  final StreamController<bool> _isTimeOutController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsTimeOut => _isTimeOutController.sink;
  Stream<bool> get outIsTimeOut => _isTimeOutController.stream;

  int indexTab = 0;
  final StreamController<int> _indexTabController =
      StreamController<int>.broadcast();
  Sink<int> get _inIndexTab => _indexTabController.sink;
  Stream<int> get outIndexTab => _indexTabController.stream;

  double currentAmountSell;

  final StreamController<double> _currentAmountSellController =
      StreamController<double>.broadcast();
  Sink<double> get _inCurrentAmountSellCoin =>
      _currentAmountSellController.sink;
  Stream<double> get outCurrentAmountSell =>
      _currentAmountSellController.stream;

  double currentAmountBuy;

  final StreamController<double> _currentAmountBuyController =
      StreamController<double>.broadcast();
  Sink<double> get _inCurrentAmountBuyCoin => _currentAmountBuyController.sink;
  Stream<double> get outCurrentAmountBuy => _currentAmountBuyController.stream;

  bool enabledSellField = false;

  final StreamController<bool> _enabledSellFieldController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inEnabledSellField => _enabledSellFieldController.sink;
  Stream<bool> get outEnabledSellField => _enabledSellFieldController.stream;

  bool isMaxActive = false;

  final StreamController<bool> _isMaxActiveController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsMaxActive => _isMaxActiveController.sink;
  Stream<bool> get outIsMaxActive => _isMaxActiveController.stream;

  @override
  void dispose() {
    _orderCoinController.close();
    _sellCoinController.close();
    _listOrderCoinController.close();
    _focusTextFieldController.close();
    _receiveCoinController.close();
    _amountReceiveController.close();
    _indexTabController.close();
    _isTimeOutController.close();
    _currentAmountSellController.close();
    _currentAmountBuyController.close();
    _enabledSellFieldController.close();
    _isMaxActiveController.close();
  }

  void setIsMaxActive(bool isMaxActive) {
    this.isMaxActive = isMaxActive;
    _inIsMaxActive.add(this.isMaxActive);
  }

  void setEnabledSellField(bool enabledSellField) {
    this.enabledSellField = enabledSellField;
    _inEnabledSellField.add(this.enabledSellField);
  }

  void setCurrentAmountSell(double amount) {
    currentAmountSell = amount;
    _inCurrentAmountSellCoin.add(currentAmountSell);
  }

  void setCurrentAmountBuy(double amount) {
    currentAmountBuy = amount;
    _inCurrentAmountBuyCoin.add(currentAmountBuy);
  }

  void setIndexTabDex(int index) {
    indexTab = index;
    _inIndexTab.add(indexTab);
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
    final List<Coin> coins = await coinsBloc.readJsonCoin();
    final List<Future<Orderbook>> futureOrderbook = <Future<Orderbook>>[];

    for (Coin coin in coins) {
      if (coin.abbr != rel.abbr) {
        futureOrderbook.add(mm2.getOrderbook(coin, rel));
      }
    }

    final List<Orderbook> orderbooks = await Future.wait(futureOrderbook);

    orderCoins = orderbooks;
    _inListOrderCoin.add(orderCoins);
  }

  String getExchangeRate() {
    if (swapBloc.orderCoin != null) {
      return '1 ${swapBloc.orderCoin.coinBase.abbr} = ${(Decimal.parse(currentAmountSell.toString()) / Decimal.parse(currentAmountBuy.toString())).toStringAsFixed(8)} ${swapBloc.orderCoin?.coinRel?.abbr}';
    } else {
      return '';
    }
  }

  String getExchangeRateUSD() {
    if (swapBloc.orderCoin != null && sellCoin.priceForOne != null) {
      final String res = ((Decimal.parse(currentAmountSell.toString()) /
                  Decimal.parse(currentAmountBuy.toString())) *
              Decimal.parse(sellCoin.priceForOne))
          .toStringAsFixed(2);
      return '($res USD)';
    } else {
      return '';
    }
  }

  void setFocusTextField(bool focus) {
    focusTextField = focus;
    _inFocusTextField.add(focusTextField);
  }

  Future<double> setReceiveAmount(
      Coin coin, String amountSell, Ask currentAsk) async {
    try {
      final Orderbook orderbook = await mm2.getOrderbook(coin, sellCoin.coin);
      String bestPrice = '0';
      double maxVolume = 0;
      int i = 0;

      if (currentAsk == null) {
        for (Ask ask in orderbook.asks) {
          if (ask.address != swapBloc.sellCoin.balance.address &&
              (i == 0 ||
                  (Decimal.parse(ask.price) <= Decimal.parse(bestPrice) &&
                      ask.maxvolume > maxVolume))) {
            maxVolume = ask.maxvolume;
            bestPrice = ask.price;
          }
          i++;
        }
      } else {
        bestPrice = currentAsk.price;
        maxVolume = currentAsk.maxvolume;
      }

      orderCoin = OrderCoin(
        coinRel: sellCoin.coin,
        coinBase: coin,
        orderbook: orderbook,
        maxVolume: maxVolume,
        bestPrice: bestPrice,
      );
      _inOrderCoin.add(orderCoin);

      amountReceive =
          double.parse(orderCoin.getBuyAmount(amountSell.replaceAll(',', '.')));

      _inAmountReceiveCoin.add(amountReceive);
      return amountReceive;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  void setTimeout(bool time) {
    isTimeOut = time;
    _inIsTimeOut.add(isTimeOut);
  }
}

SwapBloc swapBloc = SwapBloc();
