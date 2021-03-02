import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/order_coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/dex/build_swap_fees.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/swap_confirmation_page.dart';
import 'package:komodo_dex/screens/dex/trade/create/build_fiat_amount.dart';
import 'package:komodo_dex/screens/dex/trade/create/order_created_popup.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/select_receive_coin_dialog.dart';
import 'package:komodo_dex/screens/dex/trade/create/sell/select_sell_coin_dialog.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_form_validator.dart';
import 'package:komodo_dex/screens/dex/trade/exchange_rate.dart';
import 'package:komodo_dex/screens/dex/get_swap_fee.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class TradePage extends StatefulWidget {
  const TradePage({this.mContext});

  final BuildContext mContext;

  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> with TickerProviderStateMixin {
  final _ctrlAmountSell = TextEditingControllerWorkaroud();
  final _ctrlAmountReceive = TextEditingController();

  CexProvider _cexProvider;
  OrderBookProvider _orderBookProvider;

  Decimal _tmpAmountSell = deci(0);
  Ask _matchingBid;
  bool _isLoadingMax = false;

  @override
  void initState() {
    super.initState();

    initListenerAmountReceive();

    swapBloc.enabledReceiveField = false;
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);
    swapBloc.setEnabledSellField(false);
    swapBloc.setCurrentAmountBuy(null);
    swapBloc.setCurrentAmountSell(null);

    _ctrlAmountReceive.clear();
    _ctrlAmountSell.addListener(onChangeSell);
    _ctrlAmountReceive.addListener(onChangeReceive);
  }

  @override
  void dispose() {
    _ctrlAmountSell.dispose();
    _ctrlAmountReceive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cexProvider ??= Provider.of<CexProvider>(context);
    _orderBookProvider ??= Provider.of<OrderBookProvider>(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: <Widget>[
        _buildExchange(),
        const SizedBox(
          height: 8,
        ),
        _buildTradeButton(),
        StreamBuilder<Object>(
            initialData: false,
            stream: swapBloc.outIsTimeOut,
            builder: (BuildContext context, AsyncSnapshot<Object> snapshot) {
              if (snapshot.data != null && snapshot.data) {
                return ExchangeRate();
              } else {
                return Container();
              }
            }),
      ],
    );
  }

  void initListenerAmountReceive() {
    swapBloc.outAmountReceive.listen((double onData) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (onData != 0) {
          _ctrlAmountReceive.text = onData.toString();
        } else {
          _ctrlAmountReceive.text = '';
        }
      });
    });
  }

  void onChangeReceive() {
    if (_amountReceive() > 0) {
      swapBloc.setCurrentAmountBuy(_amountReceive());
    } else {
      swapBloc.setCurrentAmountBuy(null);
    }
    if (_matchingBid == null && _amountSell() > 0 && _amountReceive() > 0) {
      final Decimal bestPrice = deci(_amountReceive()) / deci(_amountSell());
      swapBloc.updateBuyCoin(OrderCoin(
          coinBase: swapBloc.receiveCoin,
          coinRel: swapBloc.sellCoinBalance?.coin,
          bestPrice: bestPrice,
          maxVolume: deci(_amountSell())));
    }
    setState(() {});
  }

  void onChangeSell() {
    final amountSell = deci(_amountSell());

    swapBloc.setCurrentAmountSell(_amountSell() == 0 ? null : _amountSell());

    setState(() {
      if (_matchingBid == null && _amountSell() > 0 && _amountReceive() > 0) {
        final Decimal bestPrice = deci(_amountReceive()) / deci(_amountSell());
        swapBloc.updateBuyCoin(OrderCoin(
            coinBase: swapBloc.receiveCoin,
            coinRel: swapBloc.sellCoinBalance?.coin,
            bestPrice: bestPrice,
            maxVolume: deci(_amountSell())));
      }

      if (amountSell != _tmpAmountSell && amountSell != deci(0)) {
        setState(() {
          if (swapBloc.receiveCoin != null && !swapBloc.enabledReceiveField) {
            swapBloc
                .setReceiveAmount(
                    swapBloc.receiveCoin, amountSell, _matchingBid)
                .then((_) {
              _checkMaxVolume();
            });
          }
          if (_amountSell() > 0 &&
              _amountReceive() > 0 &&
              swapBloc.receiveCoin != null) {
            Decimal price = amountSell / deci(_amountReceive());
            Decimal maxVolume = amountSell;

            if (_matchingBid != null) {
              price = deci(_matchingBid.price);
              maxVolume = _matchingBid.maxvolume;
            }

            swapBloc.updateBuyCoin(OrderCoin(
                coinBase: swapBloc.receiveCoin,
                coinRel: swapBloc.sellCoinBalance?.coin,
                bestPrice: price,
                maxVolume: maxVolume));
          }
          _getSellCoinFees(false).then((Decimal sellCoinFees) async {
            Log.println('trade_page:249', 'sellCoinFees $sellCoinFees');
            if (swapBloc.sellCoinBalance != null &&
                amountSell + sellCoinFees >
                    swapBloc.sellCoinBalance.balance.balance) {
              if (!swapBloc.isMaxActive) {
                await setMaxValue();
              }
            }
          });
        });
      }

      _tmpAmountSell = amountSell;
    });
  }

  void _checkMaxVolume() {
    if (deci(_amountSell()) <=
        swapBloc.orderCoin.maxVolume * swapBloc.orderCoin.bestPrice) return;

    setState(() {
      final max = swapBloc.orderCoin.maxVolume * swapBloc.orderCoin.bestPrice;
      _ctrlAmountSell.setTextAndPosition(deci2s(max));
    });
  }

  Future<Decimal> _getSellCoinFees(bool isMax) async {
    setState(() {
      _isLoadingMax = true;
    });

    final CoinBalance sellCoinBalance = swapBloc.sellCoinBalance;
    final CoinAmt fee = await GetSwapFee.totalSell(
      sellCoin: sellCoinBalance.coin.abbr,
      buyCoin: swapBloc.receiveCoin?.abbr,
      sellAmt:
          isMax ? sellCoinBalance.balance.balance.toDouble() : _amountSell(),
    );

    setState(() {
      _isLoadingMax = false;
    });

    return deci(fee.amount);
  }

  Future<void> setMaxValue() async {
    try {
      setState(() async {
        final Decimal sellCoinFee = await _getSellCoinFees(true);
        final CoinBalance sellCoinBalance = swapBloc.sellCoinBalance;
        final Decimal maxValue = sellCoinBalance.balance.balance - sellCoinFee;
        Log.println('trade_page:380', 'setting max: $maxValue');

        if (maxValue < deci(0)) {
          setState(() {
            _isLoadingMax = false;
          });
          _ctrlAmountSell.text = '';
          Scaffold.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).errorColor,
            content: sellCoinFee <
                    deci(swapBloc.minVolumeDefault(sellCoinBalance.coin.abbr))
                ? Text(AppLocalizations.of(context).minValueSell(
                    sellCoinBalance.coin.abbr,
                    '${swapBloc.minVolumeDefault(sellCoinBalance.coin.abbr)}'))
                : Text(AppLocalizations.of(context).minValueSell(
                    sellCoinBalance.coin.abbr, sellCoinFee.toStringAsFixed(8))),
          ));
        } else {
          Log.println('trade_page:398', '-----------_controllerAmountSell');
          _ctrlAmountSell.setTextAndPosition(deci2s(maxValue));
        }
      });
    } catch (e) {
      Log.println('trade_page:403', e);
    }
  }

  Widget _buildExchange() {
    return Column(
      children: <Widget>[
        _buildCard(Market.SELL),
        _buildCard(Market.RECEIVE),
      ],
    );
  }

  Widget _buildTradeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: StreamBuilder<CoinBalance>(
          initialData: swapBloc.sellCoinBalance,
          stream: swapBloc.outSellCoin,
          builder: (BuildContext context, AsyncSnapshot<CoinBalance> sellCoin) {
            return StreamBuilder<Coin>(
                initialData: swapBloc.receiveCoin,
                stream: swapBloc.outReceiveCoin,
                builder:
                    (BuildContext context, AsyncSnapshot<Coin> receiveCoin) {
                  return PrimaryButton(
                    key: const Key('trade-button'),
                    onPressed: _amountSell() > 0 &&
                            _amountReceive() > 0 &&
                            sellCoin.data != null &&
                            receiveCoin.data != null
                        ? () => _confirmSwap(context)
                        : null,
                    text: AppLocalizations.of(context).trade,
                  );
                });
          }),
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
            margin: const EdgeInsets.all(8),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 32),
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
                                          TextFormField(
                                              key: Key(
                                                  'input-text-${market.toString().toLowerCase()}'),
                                              scrollPadding:
                                                  const EdgeInsets.only(
                                                      left: 35),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                DecimalTextInputFormatter(
                                                    decimalRange: 8),
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,8})?\$'))
                                              ],
                                              controller: market == Market.SELL
                                                  ? _ctrlAmountSell
                                                  : _ctrlAmountReceive,
                                              onChanged: market == Market.SELL
                                                  ? (_) {
                                                      swapBloc.setIsMaxActive(
                                                          false);
                                                    }
                                                  : null,
                                              enabled: market == Market.RECEIVE
                                                  ? swapBloc.enabledReceiveField
                                                  : swapBloc.enabledSellField,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                      decimal: true),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2,
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration: InputDecoration(
                                                  hintStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                  hintText: market ==
                                                          Market.SELL
                                                      ? AppLocalizations.of(context)
                                                          .amountToSell
                                                      : '')),
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
                      market == Market.SELL && _amountSell() > 0
                          ? Container(
                              padding: EdgeInsets.only(top: 12),
                              child: BuildSwapFees(
                                baseCoin: swapBloc.sellCoinBalance.coin.abbr,
                                baseAmount: _amountSell(),
                                includeGasFee: true,
                                relCoin: swapBloc.receiveCoin?.abbr,
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
                _matchingBid == null && market == Market.RECEIVE
                    ? Positioned(
                        bottom: 10,
                        left: 22,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: swapBloc.receiveCoin != null
                                ? Text(
                                    AppLocalizations.of(context)
                                        .noOrder(swapBloc.receiveCoin.abbr),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )
                                : const Text('')))
                    : Container()
              ],
            ),
          ),
        ),
        if (market == Market.RECEIVE)
          Positioned(
            top: -25,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  color: Theme.of(context).backgroundColor,
                ),
                child: SvgPicture.asset(
                  'assets/svg/icon_swap.svg',
                  height: 40,
                )),
          )
      ],
    );
  }

  Widget _buildMaxButton(Market market) {
    return StreamBuilder<bool>(
      initialData: swapBloc.enabledSellField,
      stream: swapBloc.outEnabledSellField,
      builder: (BuildContext context, AsyncSnapshot<bool> anapshot) {
        return market == Market.SELL && anapshot.data
            ? InkWell(
                onTap: () async {
                  swapBloc.setIsMaxActive(true);
                  setState(() {
                    _isLoadingMax = true;
                  });
                  await setMaxValue();
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 14, 0, 12),
                  child: Text(
                    AppLocalizations.of(context).max,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Theme.of(context).accentColor),
                  ),
                ),
              )
            : Container();
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
            ? StreamBuilder<Coin>(
                initialData: swapBloc.receiveCoin,
                stream: swapBloc.outReceiveCoin,
                builder: (BuildContext context, AsyncSnapshot<Coin> snapshot) {
                  return _buildSelectorCoin(snapshot.data);
                },
              )
            : StreamBuilder<dynamic>(
                initialData: swapBloc.sellCoinBalance,
                stream: swapBloc.outSellCoin,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data != null && snapshot.data is CoinBalance) {
                    final CoinBalance coinBalance = snapshot.data;
                    return _buildSelectorCoin(coinBalance.coin);
                  } else if (snapshot.data != null &&
                      snapshot.data is OrderCoin) {
                    final OrderCoin orderCoin = snapshot.data;
                    return _buildSelectorCoin(orderCoin.coinBase);
                  } else {
                    return _buildSelectorCoin(null);
                  }
                }),
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
                      child: Text(
                coin != null ? coin.abbr : '-',
                style: Theme.of(context).textTheme.subtitle2,
                maxLines: 1,
              ))),
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

  void _replaceAllCommas() {
    _ctrlAmountSell.text = _ctrlAmountSell.text.replaceAll(',', '.');
    _ctrlAmountReceive.text = _ctrlAmountReceive.text.replaceAll(',', '.');
  }

  Future<void> _openSelectCoinDialog(Market market) async {
    _replaceAllCommas();

    if (market == Market.RECEIVE) {
      if (_amountSell() == 0) {
        _showSnackbar(AppLocalizations.of(context).enterSellAmount);
        return;
      }

      if (!_isLoadingMax) {
        openSelectReceiveCoinDialog(
          context: context,
          amountSell: _amountSell(),
          onSelect: (Ask bid) => _performTakerOrder(bid),
          onCreate: (String coin) => _performMakerOrder(coin),
        );
      }
    } else {
      openSelectSellCoinDialog(
        context: context,
        onDone: (coin) {
          swapBloc.updateSellCoin(coin);
          swapBloc.updateBuyCoin(null);
          swapBloc.updateReceiveCoin(null);
          swapBloc.setTimeout(true);
          swapBloc.setEnabledSellField(true);

          _orderBookProvider.activePair = CoinsPair(sell: coin.coin, buy: null);

          _ctrlAmountReceive.clear();
          _ctrlAmountSell.clear();
        },
      );
    }
  }

  Future<void> _performMakerOrder(String coin) async {
    _replaceAllCommas();

    setState(() => _matchingBid = null);

    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(Coin(abbr: coin));
    swapBloc.enabledReceiveField = true;

    _ctrlAmountReceive.clear();
  }

  Future<void> _performTakerOrder(Ask bid) async {
    _replaceAllCommas();

    setState(() => _matchingBid = bid);

    swapBloc.enabledReceiveField = false;
    swapBloc.updateReceiveCoin(Coin(abbr: bid.coin));
    _ctrlAmountReceive.text = deci2s(bid.getReceiveAmount(deci(_amountSell())));

    swapBloc.updateBuyCoin(OrderCoin(
        coinBase: swapBloc.receiveCoin,
        coinRel: swapBloc.sellCoinBalance?.coin,
        bestPrice: deci(_amountSell()) / deci(_amountReceive()),
        maxVolume: deci(_amountSell())));

    final Decimal askPrice = Decimal.parse(bid.price.toString());
    final Decimal amountSell = Decimal.parse(_ctrlAmountSell.text);
    final Decimal amountReceive = Decimal.parse(_ctrlAmountReceive.text);
    final Decimal maxVolume = Decimal.parse(bid.maxvolume.toString());

    if (amountReceive < (amountSell / askPrice) &&
        amountSell > maxVolume * askPrice) {
      _ctrlAmountSell.text = (maxVolume * askPrice).toStringAsFixed(8);
    }
  }

  Future<void> _confirmSwap(BuildContext mContext) async {
    _replaceAllCommas();

    final validator = TradeFormValidator(
      matchingBid: _matchingBid,
      amountSell: _amountSell(),
      amountReceive: _amountReceive(),
    );
    final errorMessage = await validator.errorMessage;

    if (errorMessage == null) {
      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => SwapConfirmation(
                  orderSuccess: () => showOrderCreatedDialog(context),
                  order: _matchingBid,
                  bestPrice: deci2s(swapBloc.orderCoin.bestPrice),
                  coinBase: swapBloc.orderCoin?.coinBase,
                  coinRel: swapBloc.orderCoin?.coinRel,
                  swapStatus: swapBloc.enabledReceiveField
                      ? SwapStatus.SELL
                      : SwapStatus.BUY,
                  amountToSell: '${_amountSell()}',
                  amountToBuy: '${_amountReceive()}',
                )),
      ).then((dynamic _) {
        setState(() => _matchingBid = null);

        _ctrlAmountReceive.clear();
        _ctrlAmountSell.clear();
      });
    } else {
      _showSnackbar(errorMessage);
    }
  }

  double _amountSell() {
    return double.tryParse(_ctrlAmountSell.text.replaceAll(',', '.')) ?? 0;
  }

  double _amountReceive() {
    return double.tryParse(_ctrlAmountReceive.text.replaceAll(',', '.')) ?? 0;
  }

  void _showSnackbar(String text) {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(text),
    ));
  }
}

enum Market {
  SELL,
  RECEIVE,
}
