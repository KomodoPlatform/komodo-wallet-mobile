import 'dart:async';
import 'package:decimal/decimal.dart';
import '../model/get_max_taker_volume.dart';
import '../model/order_book_provider.dart';
import '../services/mm.dart';
import '../services/utils.dart';
import 'package:rational/rational.dart';
import '../blocs/coins_bloc.dart';
import '../model/coin_balance.dart';
import '../model/orderbook.dart';
import '../model/trade_preimage.dart';
import '../widgets/bloc_provider.dart';

class SwapBloc implements BlocBase {
  CoinBalance sellCoinBalance;
  CoinBalance receiveCoinBalance;
  bool enabledSellField = false;
  bool enabledReceiveField = false;
  Rational amountSell;
  Rational amountReceive;
  Ask matchingBid;
  bool shouldBuyOut = false;
  bool isSellMaxActive = false;
  TradePreimage _tradePreimage;
  bool _processing = false;
  Rational maxTakerVolume;
  String _preimageError;
  String _validatorError;
  final List<String> _currentSwaps = [];
  bool autovalidate = false;

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

  final StreamController<Rational> _amountSellController =
      StreamController<Rational>.broadcast();
  Sink<Rational> get _inAmountSell => _amountSellController.sink;
  Stream<Rational> get outAmountSell => _amountSellController.stream;

  final StreamController<Rational> _amountReceiveController =
      StreamController<Rational>.broadcast();
  Sink<Rational> get _inAmountReceive => _amountReceiveController.sink;
  Stream<Rational> get outAmountReceive => _amountReceiveController.stream;

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

  final StreamController<String> _preimageErrorController =
      StreamController<String>.broadcast();
  Sink<String> get _inPreimageError => _preimageErrorController.sink;
  Stream<String> get outPreimageError => _preimageErrorController.stream;

  final StreamController<String> _validatorErrorController =
      StreamController<String>.broadcast();
  Sink<String> get _inValidatorError => _validatorErrorController.sink;
  Stream<String> get outValidatorError => _validatorErrorController.stream;

  final StreamController<List<String>> _currentSwapsController =
      StreamController<List<String>>.broadcast();
  Sink<List<String>> get _inCurrentSwaps => _currentSwapsController.sink;
  Stream<List<String>> get outCurrentSwaps => _currentSwapsController.stream;

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
    _inPreimageError.close();
    _inValidatorError.close();
    _inCurrentSwaps.close();
  }

  void setIsMaxActive(bool isMaxActive) {
    isSellMaxActive = isMaxActive;
    _inIsMaxActive.add(isSellMaxActive);
  }

  void setEnabledSellField(bool enabledSellField) {
    this.enabledSellField = enabledSellField;
    _inEnabledSellField.add(this.enabledSellField);
  }

  void setAmountSell(Rational amount) {
    amountSell = amount;
    _inAmountSell.add(amountSell);
  }

  void setAmountReceive(Rational amount) {
    amountReceive = amount;
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
    syncOrderbook.activePair = CoinsPair(sell: coinBalance?.coin, buy: null);
    sellCoinBalance = coinBalance;
    _inSellCoinBalance.add(sellCoinBalance);

    updateMaxTakerVolume();
  }

  updateFieldBalances() {
    if (sellCoinBalance == null) return;
    sellCoinBalance.balance.balance =
        Decimal.parse(maxTakerVolume.toDecimalString());
    _inSellCoinBalance.add(sellCoinBalance);

    if (amountSell == null) return;
    if (deci(amountSell) > sellCoinBalance.balance.balance) {
      setAmountSell(maxTakerVolume);
    }
  }

  Future<void> updateMaxTakerVolume() async {
    if (sellCoinBalance == null) {
      maxTakerVolume = null;
      return;
    }

    try {
      maxTakerVolume = await MM.getMaxTakerVolume(
          GetMaxTakerVolume(coin: sellCoinBalance.coin.abbr));
    } catch (_) {
      maxTakerVolume = null;
    }
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

  Timer _processingTimer;
  bool get processing => _processing;
  set processing(bool value) {
    _processingTimer?.cancel();

    // In some cases proper form proccessing requires multiple async calls
    // in sequence. To prevent UI 'flickering' between those calls we
    // use small delay before turn OFF 'processing' flag.
    // Turning 'processing' ON should be performed without delays though.
    if (value) {
      _processing = value;
      _inProcessing.add(true);
    } else {
      _processingTimer = Timer(const Duration(milliseconds: 500), () {
        _processing = value;
        _inProcessing.add(false);
      });
    }
  }

  String get preimageError => _preimageError;
  set preimageError(String value) {
    _preimageError = value;
    _inPreimageError.add(_preimageError);
  }

  String get validatorError => _validatorError;
  set validatorError(String value) {
    _validatorError = value;
    _inValidatorError.add(_validatorError);
  }

  List<String> get currentSwaps => _currentSwaps;
  set currentSwaps(List<String> value) {
    _currentSwaps.addAll(value);
    _inCurrentSwaps.add(_currentSwaps);
  }
}

SwapBloc swapBloc = SwapBloc();
