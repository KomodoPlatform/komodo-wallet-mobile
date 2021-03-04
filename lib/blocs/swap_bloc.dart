import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/dex/get_swap_fee.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class SwapBloc implements BlocBase {
  CoinBalance sellCoinBalance;
  CoinBalance receiveCoinBalance;
  bool enabledSellField = false;
  bool enabledReceiveField = false;
  double amountSell;
  double amountReceive;
  Ask matchingBid;
  bool isMaxActive = false;

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

  @override
  void dispose() {
    _sellCoinBalanceController.close();
    _receiveCoinBalanceController.close();
    _amountReceiveController.close();
    _indexTabController.close();
    _amountSellController.close();
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

  void setAmountSell(double amount) {
    amountSell = amount;
    _inAmountSell.add(amountSell);
  }

  void setAmountReceive(double amount) {
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

  double getExchangeRate() {
    if (amountSell == null) return null;
    if (amountReceive == null || amountReceive == 0) return null;

    return amountReceive / amountSell;
  }

  double minVolumeDefault(String coin) {
    // https://github.com/KomodoPlatform/AtomicDEX-mobile/pull/1013#issuecomment-770423015
    // Default min volumes hardcoded for QTUM and rest of the coins for now.
    // Should be handled on API-side in the future
    if (coin == 'QTUM') {
      return 1;
    } else {
      return 0.00777;
    }
  }

  Future<Decimal> getMaxSellAmount() async {
    final Decimal sellCoinFee = await getSellCoinFees(true);
    final CoinBalance sellCoinBalance = swapBloc.sellCoinBalance;
    return sellCoinBalance.balance.balance - sellCoinFee;
  }

  Future<Decimal> getSellCoinFees(bool max) async {
    final CoinAmt fee = await GetSwapFee.totalSell(
      sellCoin: sellCoinBalance.coin.abbr,
      buyCoin: receiveCoinBalance?.coin?.abbr,
      sellAmt: max ? sellCoinBalance.balance.balance.toDouble() : amountSell,
    );

    return deci(fee.amount);
  }
}

SwapBloc swapBloc = SwapBloc();
