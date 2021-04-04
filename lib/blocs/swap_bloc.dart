import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class SwapBloc implements BlocBase {
  CoinBalance sellCoinBalance;
  CoinBalance receiveCoinBalance;
  bool enabledSellField = false;
  bool enabledReceiveField = false;
  double amountSell;
  double amountReceive;
  Ask matchingBid;
  bool shouldBuyOut = false;
  bool isSellMaxActive = false;
  TradePreimage _tradePreimage;
  bool _processing = false;

  // Using to guide user directly to active orders list
  int indexTab = 0;

  final StreamController<CoinBalance> _receiveCoinBalanceController =
      StreamController<CoinBalance>.broadcast();
  Sink<CoinBalance> get _inReceiveCoinBalance =>
      _receiveCoinBalanceController.sink;
  Stream<CoinBalance> get outReceiveCoinBalance =>
      _receiveCoinBalanceController.stream;

  final StreamController<CoinBalance> _sellCoinBalanceController =
      StreamController<CoinBalance>.broadcast();
  Sink<CoinBalance> get _inSellCoinBalance => _sellCoinBalanceController.sink;
  Stream<CoinBalance> get outSellCoinBalance =>
      _sellCoinBalanceController.stream;

  final StreamController<double> _amountSellController =
      StreamController<double>.broadcast();
  Sink<double> get _inAmountSell => _amountSellController.sink;
  Stream<double> get outAmountSell => _amountSellController.stream;

  final StreamController<double> _amountReceiveController =
      StreamController<double>.broadcast();
  Sink<double> get _inAmountReceive => _amountReceiveController.sink;
  Stream<double> get outAmountReceive => _amountReceiveController.stream;

  final StreamController<int> _indexTabController =
      StreamController<int>.broadcast();
  Sink<int> get _inIndexTab => _indexTabController.sink;
  Stream<int> get outIndexTab => _indexTabController.stream;

  final StreamController<bool> _enabledSellFieldController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inEnabledSellField => _enabledSellFieldController.sink;
  Stream<bool> get outEnabledSellField => _enabledSellFieldController.stream;

  final StreamController<bool> _isMaxActiveController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsMaxActive => _isMaxActiveController.sink;
  Stream<bool> get outIsMaxActive => _isMaxActiveController.stream;

  final StreamController<Ask> _matchingBidController =
      StreamController<Ask>.broadcast();
  Sink<Ask> get _inMatchingBid => _matchingBidController.sink;
  Stream<Ask> get outMatchingBid => _matchingBidController.stream;

  final StreamController<TradePreimage> _tradePreimageController =
      StreamController<TradePreimage>.broadcast();
  Sink<TradePreimage> get _inTradePreimage => _tradePreimageController.sink;
  Stream<TradePreimage> get outTradePreimage => _tradePreimageController.stream;

  final StreamController<bool> _processingController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inProcessing => _processingController.sink;
  Stream<bool> get outProcessing => _processingController.stream;

  @override
  void dispose() {
    _sellCoinBalanceController.close();
    _receiveCoinBalanceController.close();
    _amountReceiveController.close();
    _indexTabController.close();
    _amountSellController.close();
    _enabledSellFieldController.close();
    _isMaxActiveController.close();
    _processingController.close();
  }

  void setIsMaxActive(bool isMaxActive) {
    isSellMaxActive = isMaxActive;
    _inIsMaxActive.add(isSellMaxActive);
  }

  void setEnabledSellField(bool enabledSellField) {
    this.enabledSellField = enabledSellField;
    _inEnabledSellField.add(this.enabledSellField);
  }

  void setAmountSell(double amount) {
    if (amount == amountSell) return;

    amountSell = amount;
    _inAmountSell.add(amountSell);
  }

  void setAmountReceive(double amount) {
    if (amount == amountReceive) return;

    amountReceive = amount;
    _inAmountReceive.add(amountReceive);
  }

  void calcAndSetAmountReceive(Decimal amountSell, Ask matchingBid) {
    if (matchingBid == null) return;

    amountReceive = amountSell.toDouble() * double.parse(matchingBid.price);
    _inAmountReceive.add(amountReceive);
  }

  void setIndexTabDex(int index) {
    indexTab = index;
    _inIndexTab.add(indexTab);
  }

  void updateReceiveCoin(String coin) {
    final CoinBalance coinBalance = coinsBloc.getBalanceByAbbr(coin);
    receiveCoinBalance = coinBalance;
    _inReceiveCoinBalance.add(coinBalance);
  }

  void updateSellCoin(CoinBalance coinBalance) {
    sellCoinBalance = coinBalance;
    _inSellCoinBalance.add(sellCoinBalance);
  }

  void updateMatchingBid(Ask bid) {
    matchingBid = bid;
    _inMatchingBid.add(matchingBid);
  }

  TradePreimage get tradePreimage => _tradePreimage;
  set tradePreimage(TradePreimage value) {
    _tradePreimage = value;
    _inTradePreimage.add(_tradePreimage);
  }

  bool get processing => _processing;
  set processing(bool value) {
    _processing = value;
    _inProcessing.add(_processing);
  }
}

SwapBloc swapBloc = SwapBloc();
