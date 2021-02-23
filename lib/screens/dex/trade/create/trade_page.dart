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
  final TextEditingControllerWorkaroud _controllerAmountSell =
      TextEditingControllerWorkaroud();
  final TextEditingController _controllerAmountReceive =
      TextEditingController();
  CoinBalance sellCoinBalance;
  Coin currentCoinToBuy;
  String tmpText = '';
  Decimal tmpAmountSell = deci(0);
  final FocusNode _focusSell = FocusNode();
  final FocusNode _focusReceive = FocusNode();

  String amountToBuy;
  bool _noOrderFound = false;
  bool isMaxActive = false;
  Ask _matchingBid;
  bool isLoadingMax = false;
  bool showDetailedFees = false;
  CexProvider cexProvider;
  OrderBookProvider orderBookProvider;

  @override
  void initState() {
    super.initState();

    swapBloc.outFocusTextField.listen((bool onData) {
      if (widget.mContext != null) {
        try {
          FocusScope.of(widget.mContext).requestFocus(_focusSell);
        } catch (e) {
          Log.println('trade_page:72', 'deactivated widget: ' + e.toString());
        }
      }
    });
    _noOrderFound = false;
    initListenerAmountReceive();
    swapBloc.enabledReceiveField = false;

    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);
    swapBloc.setEnabledSellField(false);
    swapBloc.setCurrentAmountBuy(null);
    swapBloc.setCurrentAmountSell(null);

    _controllerAmountReceive.clear();
    _controllerAmountSell.addListener(onChangeSell);
    _controllerAmountReceive.addListener(onChangeReceive);
  }

  @override
  void dispose() {
    _controllerAmountSell.dispose();
    _controllerAmountReceive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);
    orderBookProvider ??= Provider.of<OrderBookProvider>(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: <Widget>[
        _buildExchange(),
        const SizedBox(
          height: 8,
        ),
        _buildButton(),
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
          _controllerAmountReceive.text = onData.toString();
        } else {
          _controllerAmountReceive.text = '';
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
    if (_noOrderFound && _amountSell() > 0 && _amountReceive() > 0) {
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

    if (_controllerAmountSell.text.isNotEmpty) {
      swapBloc.setCurrentAmountSell(amountSell.toDouble());
    } else {
      swapBloc.setCurrentAmountSell(null);
    }
    setState(() {
      if (_noOrderFound && _amountSell() > 0 && _amountReceive() > 0) {
        final Decimal bestPrice = deci(_amountReceive()) / deci(_amountSell());
        swapBloc.updateBuyCoin(OrderCoin(
            coinBase: swapBloc.receiveCoin,
            coinRel: swapBloc.sellCoinBalance?.coin,
            bestPrice: bestPrice,
            maxVolume: deci(_amountSell())));
      }
      if (amountSell != tmpAmountSell && amountSell != deci(0)) {
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
            if (sellCoinBalance != null &&
                amountSell + sellCoinFees > sellCoinBalance.balance.balance) {
              if (!swapBloc.isMaxActive) {
                await setMaxValue();
              }
            }
          });
        });
      }

      tmpAmountSell = amountSell;
    });
  }

  void _checkMaxVolume() {
    if (deci(_amountSell()) <=
        swapBloc.orderCoin.maxVolume * swapBloc.orderCoin.bestPrice) return;

    setState(() {
      final max = swapBloc.orderCoin.maxVolume * swapBloc.orderCoin.bestPrice;
      _controllerAmountSell.setTextAndPosition(deci2s(max));
    });
  }

  Future<Decimal> _getSellCoinFees(bool isMax) async {
    setState(() {
      isLoadingMax = true;
    });

    final CoinAmt fee = await GetSwapFee.totalSell(
      sellCoin: sellCoinBalance.coin.abbr,
      buyCoin: swapBloc.receiveCoin?.abbr,
      sellAmt:
          isMax ? sellCoinBalance.balance.balance.toDouble() : _amountSell(),
    );

    setState(() {
      isLoadingMax = false;
    });

    return deci(fee.amount);
  }

  Future<void> setMaxValue() async {
    try {
      setState(() async {
        final Decimal sellCoinFee = await _getSellCoinFees(true);
        final Decimal maxValue = sellCoinBalance.balance.balance - sellCoinFee;
        Log.println('trade_page:380', 'setting max: $maxValue');

        if (maxValue < deci(0)) {
          setState(() {
            isLoadingMax = false;
          });
          _controllerAmountSell.text = '';
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
          _focusSell.unfocus();
        } else {
          Log.println('trade_page:398', '-----------_controllerAmountSell');
          _controllerAmountSell.setTextAndPosition(deci2s(maxValue));
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

  Widget _buildButton() {
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
    double paddingRight = 24;

    return StreamBuilder<bool>(
        initialData: swapBloc.enabledSellField,
        stream: swapBloc.outEnabledSellField,
        builder:
            (BuildContext context, AsyncSnapshot<bool> enabledSellFieldStream) {
          if (market == Market.SELL && enabledSellFieldStream.data) {
            paddingRight = 4;
          } else {
            paddingRight = 24;
          }

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
                        padding: EdgeInsets.only(
                            left: 24, right: paddingRight, top: 32, bottom: 32),
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
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        market == Market.SELL
                                            ? AppLocalizations.of(context).sell
                                            : AppLocalizations.of(context)
                                                .receiveLower,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    focusNode: market == Market.SELL
                                                        ? _focusSell
                                                        : _focusReceive,
                                                    controller: market == Market.SELL
                                                        ? _controllerAmountSell
                                                        : _controllerAmountReceive,
                                                    onChanged:
                                                        market == Market.SELL
                                                            ? (_) {
                                                                swapBloc
                                                                    .setIsMaxActive(
                                                                        false);
                                                              }
                                                            : null,
                                                    enabled: market == Market.RECEIVE
                                                        ? swapBloc
                                                            .enabledReceiveField
                                                        : swapBloc
                                                            .enabledSellField,
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
                                                                fontWeight: FontWeight.w400),
                                                        hintText: market == Market.SELL ? AppLocalizations.of(context).amountToSell : '')),
                                                const SizedBox(height: 2),
                                                BuildFiatAmount(market),
                                              ],
                                            ),
                                          ),
                                          market == Market.SELL &&
                                                  enabledSellFieldStream.data
                                              ? Container(
                                                  child: FlatButton(
                                                    onPressed: () async {
                                                      swapBloc
                                                          .setIsMaxActive(true);
                                                      setState(() {
                                                        isLoadingMax = true;
                                                      });
                                                      await setMaxValue();
                                                    },
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .max,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor),
                                                    ),
                                                  ),
                                                )
                                              : Container()
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
                                      baseCoin: sellCoinBalance.coin.abbr,
                                      baseAmount: _amountSell(),
                                      includeGasFee: true,
                                      relCoin: swapBloc.receiveCoin?.abbr,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                      _noOrderFound && market == Market.RECEIVE
                          ? Positioned(
                              bottom: 10,
                              left: 22,
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: swapBloc.receiveCoin != null
                                      ? Text(
                                          AppLocalizations.of(context).noOrder(
                                              swapBloc.receiveCoin.abbr),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(32)),
                        color: Theme.of(context).backgroundColor,
                      ),
                      child: SvgPicture.asset(
                        'assets/svg/icon_swap.svg',
                        height: 40,
                      )),
                )
            ],
          );
        });
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
          _replaceAllCommas();

          if (swapBloc.enabledSellField &&
              _amountSell() == 0 &&
              market == Market.RECEIVE) {
            FocusScope.of(context).requestFocus(_focusSell);
          } else {
            _openSelectCoinDialog(market);
          }
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
                    sellCoinBalance = coinBalance;
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
    _controllerAmountSell.text =
        _controllerAmountSell.text.replaceAll(',', '.');
    _controllerAmountReceive.text =
        _controllerAmountReceive.text.replaceAll(',', '.');
  }

  Future<void> _openSelectCoinDialog(Market market) async {
    if (market == Market.RECEIVE) {
      if (!isLoadingMax && _amountSell() > 0) {
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
          swapBloc.updateBuyCoin(null);
          swapBloc.updateReceiveCoin(null);
          swapBloc.setTimeout(true);
          swapBloc.setEnabledSellField(true);
          swapBloc.updateSellCoin(coin);
          swapBloc.updateBuyCoin(null);

          orderBookProvider.activePair = CoinsPair(sell: coin.coin, buy: null);

          _controllerAmountReceive.clear();
          _controllerAmountSell.clear();
          setState(() {
            sellCoinBalance = coin;
          });
        },
      );
    }
  }

  Future<void> _performMakerOrder(String coin) async {
    _replaceAllCommas();

    setState(() {
      _matchingBid = null;
      _noOrderFound = true;
    });

    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(Coin(abbr: coin));
    swapBloc.enabledReceiveField = true;

    _controllerAmountReceive.clear();
  }

  Future<void> _performTakerOrder(Ask bid) async {
    _replaceAllCommas();

    setState(() {
      _matchingBid = bid;
      _noOrderFound = false;
    });

    swapBloc.enabledReceiveField = false;
    swapBloc.updateReceiveCoin(Coin(abbr: bid.coin));
    _controllerAmountReceive.text =
        deci2s(bid.getReceiveAmount(deci(_amountSell())));

    swapBloc.updateBuyCoin(OrderCoin(
        coinBase: swapBloc.receiveCoin,
        coinRel: swapBloc.sellCoinBalance?.coin,
        bestPrice: deci(_amountSell()) / deci(_amountReceive()),
        maxVolume: deci(_amountSell())));

    final Decimal askPrice = Decimal.parse(bid.price.toString());
    final Decimal amountSell = Decimal.parse(_controllerAmountSell.text);
    final Decimal amountReceive = Decimal.parse(_controllerAmountReceive.text);
    final Decimal maxVolume = Decimal.parse(bid.maxvolume.toString());

    if (amountReceive < (amountSell / askPrice) &&
        amountSell > maxVolume * askPrice) {
      _controllerAmountSell.text = (maxVolume * askPrice).toStringAsFixed(8);
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
        setState(() {
          _matchingBid = null;
          _noOrderFound = false;
        });
        _controllerAmountReceive.clear();
        _controllerAmountSell.clear();
      });
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(errorMessage),
      ));
    }
  }

  double _amountSell() {
    return double.tryParse(_controllerAmountSell.text.replaceAll(',', '.')) ??
        0;
  }

  double _amountReceive() {
    return double.tryParse(
            _controllerAmountReceive.text.replaceAll(',', '.')) ??
        0;
  }
}

enum Market {
  SELL,
  RECEIVE,
}
