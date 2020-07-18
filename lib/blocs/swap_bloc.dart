import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/order_coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class SwapBloc implements BlocBase {
  OrderCoin orderCoin;
  CoinBalance sellCoinBalance;
  CoinBalance buyCoinBalance;
  bool enabledReceiveField;

  final StreamController<OrderCoin> _orderCoinController =
      StreamController<OrderCoin>.broadcast();
  Sink<OrderCoin> get _inOrderCoin => _orderCoinController.sink;
  Stream<OrderCoin> get outOrderCoin => _orderCoinController.stream;

  final StreamController<double> _buyCoinUsdController =
      StreamController<double>.broadcast();
  Sink<double> get _inBuyCoinUsd => _buyCoinUsdController.sink;
  Stream<double> get outBuyCoinUsd => _buyCoinUsdController.stream;

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
    _buyCoinUsdController.close();
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

    try {
      buyCoinBalance = coinsBloc.coinBalance.firstWhere(
          (balance) => balance.coin.abbr == orderCoin.coinBase.abbr);
    } catch (_) {
      buyCoinBalance = null;
    }
  }

  void updateReceiveCoin(Coin receiveCoin) {
    Coin coin = receiveCoin;
    if (receiveCoin != null &&
        receiveCoin.abbr != null &&
        receiveCoin.abbr.isNotEmpty) {
      for (CoinBalance coinBalance in coinsBloc.coinBalance) {
        if (coinBalance.coin.abbr == receiveCoin.abbr) {
          coin = coinBalance.coin;
        }
      }
    }
    this.receiveCoin = coin;
    _inReceiveCoin.add(this.receiveCoin);
  }

  void updateSellCoin(CoinBalance coinBalance) {
    sellCoinBalance = coinBalance;
    _inSellCoin.add(sellCoinBalance);
  }

  Future<void> getBuyCoins(Coin rel) async {
    final List<Coin> coins = await coinsBloc.electrumCoins();
    final List<Future<dynamic>> futureOrderbook = <Future<dynamic>>[];

    for (Coin coin in coins) {
      if (coin.abbr != rel.abbr) {
        futureOrderbook.add(MM.getOrderbook(
            MMService().client, GetOrderbook(base: coin.abbr, rel: rel.abbr)));
      }
    }

    final List<dynamic> orderbooks =
        await Future.wait<dynamic>(futureOrderbook);

    final List<Orderbook> orderBooksList = <Orderbook>[];

    for (dynamic item in orderbooks) {
      if (item is Orderbook) {
        orderBooksList.add(item);
      }
    }
    orderCoins = orderBooksList;
    _inListOrderCoin.add(orderCoins);
  }

  double getExchangeRate() {
    if (currentAmountSell == null) return null;
    if (currentAmountBuy == null || currentAmountBuy == 0) return null;

    return currentAmountSell / currentAmountBuy;
  }

  double getCExchangeRate() {
    if (buyCoinBalance?.priceForOne == null ||
        double.parse(buyCoinBalance.priceForOne) == 0) return null;
    if (sellCoinBalance?.priceForOne == null ||
        double.parse(sellCoinBalance.priceForOne) == 0) return null;

    return double.parse(buyCoinBalance.priceForOne) /
        double.parse(sellCoinBalance.priceForOne);
  }

  void setFocusTextField(bool focus) {
    focusTextField = focus;
    _inFocusTextField.add(focusTextField);
  }

  Future<double> setReceiveAmount(
      Coin coin, Decimal amountSell, Ask currentAsk) async {
    try {
      final Orderbook orderbook = await MM.getOrderbook(MMService().client,
          GetOrderbook(base: coin.abbr, rel: sellCoinBalance.coin.abbr));
      Decimal bestPrice = deci(0);
      Decimal maxVolume = deci(0);
      int i = 0;

      if (currentAsk == null) {
        for (Ask ask in orderbook.asks) {
          if (ask.address != swapBloc.sellCoinBalance.balance.address &&
              (i == 0 ||
                  (deci(ask.price) <= bestPrice &&
                      ask.maxvolume > maxVolume))) {
            maxVolume = ask.maxvolume;
            bestPrice = deci(ask.price);
          }
          i++;
        }
      } else {
        bestPrice = deci(currentAsk.price);
        maxVolume = currentAsk.maxvolume;
      }

      orderCoin = OrderCoin(
        coinRel: sellCoinBalance.coin,
        coinBase: coin,
        orderbook: orderbook,
        maxVolume: maxVolume,
        bestPrice: bestPrice,
      );
      _inOrderCoin.add(orderCoin);

      amountReceive = orderCoin.getBuyAmount(amountSell).toDouble();

      _inAmountReceiveCoin.add(amountReceive);

      final buyCoinUsd =
          cexPrices.getPrice(swapBloc.orderCoin.coinBase.abbr, 'usd');
      _inBuyCoinUsd.add(buyCoinUsd);

      return amountReceive;
    } catch (e) {
      Log.println('swap_bloc:257', e);
      return 0;
    }
  }

  void setTimeout(bool time) {
    isTimeOut = time;
    _inIsTimeOut.add(isTimeOut);
  }
}

SwapBloc swapBloc = SwapBloc();
