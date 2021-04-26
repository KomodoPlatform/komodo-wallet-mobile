import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/build_detailed_fees.dart';
import 'package:komodo_dex/screens/dex/trade/create/auto_scroll_text.dart';
import 'package:komodo_dex/screens/dex/trade/create/build_fiat_amount.dart';
import 'package:komodo_dex/screens/dex/trade/create/build_reset_button.dart';
import 'package:komodo_dex/screens/dex/trade/create/build_trade_button.dart';
import 'package:komodo_dex/screens/dex/trade/create/preimage_error.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/receive_amount_field.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/select_receive_coin_dialog.dart';
import 'package:komodo_dex/screens/dex/trade/create/sell/select_sell_coin_dialog.dart';
import 'package:komodo_dex/screens/dex/trade/create/sell/sell_amount_field.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_form_validator.dart';
import 'package:komodo_dex/screens/dex/trade/evaluation.dart';
import 'package:komodo_dex/screens/dex/trade/exchange_rate.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class TradePage extends StatefulWidget {
  const TradePage({this.mContext});

  final BuildContext mContext;

  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> with TickerProviderStateMixin {
  CexProvider _cexProvider;
  OrderBookProvider _orderBookProvider;
  final _listeners = <StreamSubscription<dynamic>>[];
  Timer _updateTimer;

  @override
  void initState() {
    _listeners.add(swapBloc.outAmountSell.listen(_onFormStateChange));
    _listeners.add(swapBloc.outAmountReceive.listen(_onFormStateChange));

    _onFormStateChange(null);

    super.initState();
  }

  @override
  void dispose() {
    _listeners.map((listener) => listener?.cancel());
    _updateTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cexProvider ??= Provider.of<CexProvider>(context);
    _orderBookProvider ??= Provider.of<OrderBookProvider>(context);

    return Column(
      children: <Widget>[
        _buildProgressBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildExchange(),
                SizedBox(height: 8),
                _buildFeesOrError(),
                SizedBox(height: 8),
                ExchangeRate(alignCenter: true),
                SizedBox(height: 8),
                Evaluation(alignCenter: true),
                SizedBox(height: 20),
                BuildTradeButton(),
                BuildResetButton(),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<bool>(
      initialData: swapBloc.processing,
      stream: swapBloc.outProcessing,
      builder: (context, snapshot) {
        return SizedBox(
          height: 1,
          child: snapshot.data ? LinearProgressIndicator() : SizedBox(),
        );
      },
    );
  }

  Widget _buildExchange() {
    return Column(
      children: <Widget>[
        _buildCard(Market.SELL),
        _buildCard(Market.RECEIVE),
      ],
    );
  }

  Widget _buildCard(Market market) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          width: double.infinity,
          child: Card(
            elevation: 8,
            margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(left: 24, right: 24, top: 28, bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context).selectCoin,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Container(
                                width: 130,
                                child: _buildCoinSelect(market),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  market == Market.SELL
                                      ? AppLocalizations.of(context).sell
                                      : AppLocalizations.of(context)
                                          .receiveLower,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          market == Market.SELL
                                              ? SellAmountField()
                                              : ReceiveAmountField(),
                                          const SizedBox(height: 2),
                                          BuildFiatAmount(market),
                                        ],
                                      ),
                                    ),
                                    _buildMaxButton(market),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (market == Market.RECEIVE)
          Positioned(
            top: -21,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  color: Theme.of(context).backgroundColor,
                ),
                child: SvgPicture.asset(
                  settingsBloc.isLightTheme
                      ? 'assets/svg_light/icon_swap.svg'
                      : 'assets/svg/icon_swap.svg',
                  height: 40,
                )),
          )
      ],
    );
  }

  Widget _buildFeesOrError() {
    return StreamBuilder<String>(
        initialData: swapBloc.preimageError,
        stream: swapBloc.outPreimageError,
        builder: (context, preimageError) {
          if (preimageError.data != null) {
            return Container(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 10),
                child: PreimageError(preimageError.data));
          } else {
            return StreamBuilder<String>(
                initialData: swapBloc.validatorError,
                stream: swapBloc.outValidatorError,
                builder: (context, validatorError) {
                  if (validatorError.data != null) {
                    return Container(
                        padding: EdgeInsets.fromLTRB(24, 12, 24, 10),
                        child: Text(
                          validatorError.data,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Theme.of(context).errorColor),
                        ));
                  } else {
                    return StreamBuilder<TradePreimage>(
                        initialData: swapBloc.tradePreimage,
                        stream: swapBloc.outTradePreimage,
                        builder: (context, snapshot) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                            child: BuildDetailedFees(
                              preimage: snapshot.data,
                              alignCenter: true,
                            ),
                          );
                        });
                  }
                });
          }
        });
  }

  Widget _buildMaxButton(Market market) {
    return StreamBuilder<bool>(
      initialData: swapBloc.enabledSellField,
      stream: swapBloc.outEnabledSellField,
      builder: (context, enabledSnapshot) {
        return market == Market.SELL && enabledSnapshot.data
            ? InkWell(
                onTap: tradeForm.setMaxSellAmount,
                child: StreamBuilder<bool>(
                    initialData: swapBloc.isSellMaxActive,
                    stream: swapBloc.outIsMaxActive,
                    builder: (context, maxSnapshot) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(12, 18, 0, 12),
                        child: Text(
                          AppLocalizations.of(context).max,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: maxSnapshot.data
                                ? Theme.of(context).accentColor
                                : null,
                          ),
                        ),
                      );
                    }),
              )
            : SizedBox();
      },
    );
  }

  Widget _buildCoinSelect(Market market) {
    Log.println(
        'trade_page:719', 'coin-select-${market.toString().toLowerCase()}');
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: InkWell(
        key: Key('coin-select-${market.toString().toLowerCase()}'),
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          _openSelectCoinDialog(market);
        },
        child: market == Market.RECEIVE
            ? StreamBuilder<CoinBalance>(
                initialData: swapBloc.receiveCoinBalance,
                stream: swapBloc.outReceiveCoinBalance,
                builder: (context, snapshot) =>
                    _buildSelectorCoin(snapshot.data?.coin),
              )
            : StreamBuilder<CoinBalance>(
                initialData: swapBloc.sellCoinBalance,
                stream: swapBloc.outSellCoinBalance,
                builder: (context, snapshot) =>
                    _buildSelectorCoin(snapshot.data?.coin)),
      ),
    );
  }

  Widget _buildSelectorCoin(Coin coin) {
    return Opacity(
      opacity: coin == null ? 0.2 : 1,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 8,
          ),
          Row(
            children: <Widget>[
              coin != null
                  ? Image.asset(
                      'assets/${coin.abbr.toLowerCase()}.png',
                      height: 25,
                    )
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      radius: 12,
                    ),
              Expanded(
                child: Center(
                  child: AutoScrollText(
                    text: coin?.abbr ?? '-',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.grey,
            height: 1,
            width: double.infinity,
          )
        ],
      ),
    );
  }

  Future<void> _openSelectCoinDialog(Market market) async {
    if (market == Market.RECEIVE) {
      if (swapBloc.amountSell == null || swapBloc.amountSell <= 0) {
        _showSnackbar(AppLocalizations.of(context).enterSellAmount);
        return;
      }

      if (!swapBloc.processing) {
        openSelectReceiveCoinDialog(
          context: context,
          amountSell: swapBloc.amountSell,
          onSelect: (Ask bid) => _performTakerOrder(bid),
          onCreate: (String coin) => _performMakerOrder(coin),
        );
      }
    } else {
      openSelectSellCoinDialog(
        context: context,
        onDone: (coin) {
          tradeForm.reset();
          Log('trade_page', 'sell coin selected: ${coin.coin.abbr}');

          swapBloc.updateSellCoin(coin);
          swapBloc.setEnabledSellField(true);
          _orderBookProvider.activePair = CoinsPair(sell: coin.coin, buy: null);
        },
      );
    }
  }

  Future<void> _performMakerOrder(String coin) async {
    Log('trade_page', 'receive coin selected: $coin...');
    Log('trade_page', 'performing maker order');

    FocusScope.of(context).requestFocus(FocusNode());
    swapBloc.updateMatchingBid(null);
    if (swapBloc.isSellMaxActive) tradeForm.setMaxSellAmount();

    swapBloc.updateReceiveCoin(coin);
    swapBloc.setAmountReceive(null);
    swapBloc.enabledReceiveField = true;
  }

  Future<void> _performTakerOrder(Ask bid) async {
    Log('trade_page', 'receive coin selected: ${bid.coin}...');
    Log('trade_page', 'performing taker order');

    FocusScope.of(context).requestFocus(FocusNode());
    swapBloc.updateMatchingBid(bid);
    if (swapBloc.isSellMaxActive) tradeForm.setMaxSellAmount();

    swapBloc.enabledReceiveField = false;
    swapBloc.updateReceiveCoin(bid.coin);
    swapBloc.setAmountReceive(
        bid.getReceiveAmount(deci(swapBloc.amountSell)).toDouble());

    final Decimal amountSell = Decimal.parse(swapBloc.amountSell.toString());
    final Decimal bidPrice = Decimal.parse(bid.price.toString());
    final Decimal bidVolume = Decimal.parse(bid.maxvolume.toString());

    if (amountSell > bidVolume * bidPrice) {
      swapBloc.setAmountSell((bidVolume * bidPrice).toDouble());
      swapBloc.setIsMaxActive(false);
    }
  }

  void _showSnackbar(String text) {
    if (context == null) return;

    Scaffold.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(text),
    ));
  }

  Future<void> _onFormStateChange(dynamic _) async {
    _updateTimer?.cancel();
    _updateTimer = Timer(Duration(milliseconds: 500), () async {
      _updateAutovalidate();

      await _updateFees();
      if (swapBloc.autovalidate) _validate();

      await _updateSellAmountIfMax();
    });
  }

  Future<void> _updateFees() async {
    if (!mounted) return;
    swapBloc.preimageError = null;
    final String error = await tradeForm.updateTradePreimage();

    if (error != null) {
      swapBloc.preimageError = error;
    }
  }

  Future<void> _updateSellAmountIfMax() async {
    if (swapBloc.isSellMaxActive) tradeForm.setMaxSellAmount();
  }

  void _updateAutovalidate() {
    // We don't want to interrupt user while she is filling the
    // form for the first time, so autovalidation is turned off by default,
    // and we turn it on only on some conditions: if all fields are
    // filled and non-zero, or if creating taker-swap
    final bool startAutovalidation = swapBloc.matchingBid != null ||
        swapBloc.sellCoinBalance != null &&
            (swapBloc.amountSell ?? 0) > 0 &&
            swapBloc.receiveCoinBalance != null &&
            (swapBloc.amountReceive ?? 0) > 0;

    if (startAutovalidation) swapBloc.autovalidate = true;
  }

  Future<void> _validate() async {
    final TradeFormValidator validator = TradeFormValidator();
    swapBloc.validatorError = await validator.errorMessage;
  }
}

enum Market {
  SELL,
  RECEIVE,
}
