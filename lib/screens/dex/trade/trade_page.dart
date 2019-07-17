import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_coin.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/screens/dex/trade/swap_confirmation_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

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
  CoinBalance currentCoinBalance;
  Coin currentCoinToBuy;
  String tmpText = '';
  String tmpAmountSell = '';
  final FocusNode _focusSell = FocusNode();
  final FocusNode _focusReceive = FocusNode();
  Animation<double> animationInputSell;
  AnimationController controllerAnimationInputSell;
  Animation<double> animationCoinSell;
  AnimationController controllerAnimationCoinSell;
  String amountToBuy;
  dynamic timerGetOrderbook;
  bool _noOrderFound = false;
  bool enabledSellField = false;

  @override
  void initState() {
    super.initState();
    swapBloc.outFocusTextField.listen((bool onData) {
      FocusScope.of(context).requestFocus(_focusSell);
    });
    _noOrderFound = false;
    initListenerAmountReceive();
    swapBloc.enabledReceiveField = false;

    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);

    _controllerAmountReceive.clear();
    _controllerAmountSell.addListener(onChangeSell);
    _controllerAmountReceive.addListener(onChangeReceive);

    _initAnimationCoin();
    _initAnimationSell();
  }

  void _initAnimationCoin() {
    controllerAnimationCoinSell = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    animationCoinSell = CurvedAnimation(
        parent: controllerAnimationCoinSell, curve: Curves.easeIn);
    controllerAnimationCoinSell.forward();
    controllerAnimationCoinSell.duration = const Duration(milliseconds: 500);
  }

  void _initAnimationSell() {
    controllerAnimationInputSell = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    animationInputSell = CurvedAnimation(
        parent: controllerAnimationInputSell, curve: Curves.easeIn);
    controllerAnimationInputSell.forward();
    controllerAnimationInputSell.duration = const Duration(milliseconds: 500);
  }

  @override
  void dispose() {
    _controllerAmountSell.dispose();
    controllerAnimationInputSell.dispose();
    controllerAnimationCoinSell.dispose();
    if (timerGetOrderbook != null) {
      timerGetOrderbook.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: <Widget>[
        _buildExchange(),
        StreamBuilder<Object>(
            initialData: false,
            stream: swapBloc.outIsTimeOut,
            builder: (BuildContext context, AsyncSnapshot<Object> snapshot) {
              if (snapshot.hasData && snapshot.data) {
                return ExchangeRate();
              } else {
                return Container(
                  height: 84,
                );
              }
            }),
        _buildButton()
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
    if (_controllerAmountReceive.text.isNotEmpty) {
      swapBloc.setCurrentAmountBuy(double.parse(_controllerAmountReceive.text));
    }
    if (_noOrderFound &&
        _controllerAmountReceive.text.isNotEmpty &&
        _controllerAmountSell.text.isNotEmpty) {
      swapBloc.updateBuyCoin(OrderCoin(
          coinBase: swapBloc.receiveCoin,
          coinRel: swapBloc.sellCoin?.coin,
          bestPrice:
              double.parse(_controllerAmountReceive.text.replaceAll(',', '.')) /
                  double.parse(_controllerAmountSell.text.replaceAll(',', '.')),
          maxVolume:
              double.parse(_controllerAmountSell.text.replaceAll(',', '.'))));
    }
  }

  void onChangeSell() {
    if (_controllerAmountSell.text.isNotEmpty) {
      swapBloc.setCurrentAmountSell(double.parse(_controllerAmountSell.text));
    }
    setState(() {
      final String amountSell = _controllerAmountSell.text.replaceAll(',', '.');
      if (amountSell != tmpAmountSell && amountSell.isNotEmpty) {
        setState(() {
          getTradeFee().then((double tradeFee) {
            print(double.parse(currentCoinBalance.balance.getBalance()));
            print(double.parse(amountSell) + tradeFee);
            print(tradeFee);
            if (currentCoinBalance != null &&
                double.parse(amountSell) + tradeFee >
                    double.parse(currentCoinBalance.balance.getBalance())) {
              setMaxValue();
            } else {
              if (amountSell.contains(
                  RegExp('^\$|^(0|([1-9][0-9]{0,3}))([.,]{1}[0-9]{0,8})?\$'))) {
              } else {
                // _controllerAmountSell.text = tmpText;
                _controllerAmountSell
                    .setTextAndPosition(replaceAllTrainlingZero(tmpText));
              }
            }
          });

          if (swapBloc.receiveCoin != null && !swapBloc.enabledReceiveField) {
            swapBloc
                .setReceiveAmount(
                    swapBloc.receiveCoin, _controllerAmountSell.text)
                .then((_) {
              _checkMaxVolume();
            });
          }
          if (_noOrderFound &&
              _controllerAmountReceive.text.isNotEmpty &&
              _controllerAmountSell.text.isNotEmpty &&
              swapBloc.receiveCoin != null) {
            swapBloc.updateBuyCoin(OrderCoin(
                coinBase: swapBloc.receiveCoin,
                coinRel: swapBloc.sellCoin?.coin,
                bestPrice: double.parse(
                        _controllerAmountSell.text.replaceAll(',', '.')) /
                    double.parse(
                        _controllerAmountReceive.text.replaceAll(',', '.')),
                maxVolume: double.parse(
                    _controllerAmountSell.text.replaceAll(',', '.'))));
          }
        });
      }

      tmpAmountSell = amountSell;
    });
  }

  void _checkMaxVolume() {
    if (double.parse(_controllerAmountSell.text) >=
        swapBloc.orderCoin.maxVolume * swapBloc.orderCoin.bestPrice) {
      _setMaxVolumeSell();
    }
  }

  Future<double> getTradeFee() async {
    try {
      final TradeFee tradeFeeResponse =
          await mm2.getTradeFee(currentCoinBalance.coin);
      final double tradeFee = double.parse(tradeFeeResponse.result.amount);

      return (2 * tradeFee) +
          ((1 / 777) * double.parse(_controllerAmountSell.text));
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<void> setMaxValue() async {
    try {
      setState(() async {
        final double maxValue =
            double.parse(currentCoinBalance.balance.getBalance()) -
                await getTradeFee();
        if (maxValue < 0) {
          _controllerAmountSell.text = '';
          Scaffold.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).errorColor,
            content: const Text('Your balance is to small including fee.'),
          ));
          _focusSell.unfocus();
        } else {
          _controllerAmountSell.setTextAndPosition(
              replaceAllTrainlingZero(maxValue.toStringAsFixed(8)));
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _setMaxVolumeSell() {
    setState(() {
      _controllerAmountSell.setTextAndPosition(replaceAllTrainlingZero(
          (swapBloc.orderCoin.maxVolume * swapBloc.orderCoin.bestPrice)
              .toStringAsFixed(8)
              .replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '')));
    });
  }

  Widget _buildExchange() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildCard(Market.SELL),
            _buildCard(Market.RECEIVE)
          ],
        ),
        Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              color: Theme.of(context).backgroundColor,
            ),
            child: SvgPicture.asset(
              'assets/icon_swap.svg',
              height: 40,
            ))
      ],
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: StreamBuilder<CoinBalance>(
          initialData: swapBloc.sellCoin,
          stream: swapBloc.outSellCoin,
          builder: (BuildContext context, AsyncSnapshot<CoinBalance> sellCoin) {
            return StreamBuilder<Coin>(
                initialData: swapBloc.receiveCoin,
                stream: swapBloc.outReceiveCoin,
                builder:
                    (BuildContext context, AsyncSnapshot<Coin> receiveCoin) {
                  return PrimaryButton(
                    onPressed: _controllerAmountSell.text.isNotEmpty &&
                            _controllerAmountReceive.text.isNotEmpty &&
                            sellCoin.hasData &&
                            receiveCoin.hasData
                        ? () => _confirmSwap(context)
                        : null,
                    text: AppLocalizations.of(context).trade,
                  );
                });
          }),
    );
  }

  void _animCoin(Market market) {
    if (!enabledSellField && market == Market.SELL) {
      controllerAnimationCoinSell.reset();
      controllerAnimationCoinSell.forward();
    }
  }

  Widget _buildCard(Market market) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.all(8),
        color: Theme.of(context).primaryColor,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 32, bottom: 52),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).selectCoin,
                        style: Theme.of(context).textTheme.body2,
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
                              : AppLocalizations.of(context).receiveLower,
                          style: Theme.of(context).textTheme.body2,
                        ),
                        StreamBuilder<bool>(
                            initialData: true,
                            stream: swapBloc.outIsTimeOut,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              return Stack(
                                children: <Widget>[
                                  FadeTransition(
                                    opacity: animationInputSell,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () => _animCoin(market),
                                      child: TextFormField(
                                          scrollPadding:
                                              const EdgeInsets.only(left: 35),
                                          inputFormatters: <TextInputFormatter>[
                                            DecimalTextInputFormatter(
                                                decimalRange: 8),
                                            WhitelistingTextInputFormatter(RegExp(
                                                '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,8})?\$'))
                                          ],
                                          focusNode: market == Market.SELL
                                              ? _focusSell
                                              : _focusReceive,
                                          controller: market == Market.SELL
                                              ? _controllerAmountSell
                                              : _controllerAmountReceive,
                                          enabled: market == Market.RECEIVE
                                              ? swapBloc.enabledReceiveField
                                              : enabledSellField,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          style:
                                              Theme.of(context).textTheme.title,
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .body2
                                                  .copyWith(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400),
                                              hintText: market == Market.SELL
                                                  ? AppLocalizations.of(context)
                                                      .amountToSell
                                                  : '')),
                                    ),
                                  ),
                                  market == Market.RECEIVE && !snapshot.data
                                      ? Positioned(
                                          bottom: 15,
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)
                                                    .loadingOrderbook,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .body2,
                                              )
                                            ],
                                          ),
                                        )
                                      : Container()
                                ],
                              );
                            })
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _noOrderFound && market == Market.RECEIVE
                ? Positioned(
                    bottom: 10,
                    left: 22,
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: swapBloc.receiveCoin != null
                            ? Text(
                                AppLocalizations.of(context)
                                    .noOrder(swapBloc.receiveCoin.abbr),
                                style: Theme.of(context).textTheme.body2,
                              )
                            : const Text('')))
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _buildCoinSelect(Market market) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () async {
        if (_controllerAmountSell.text.isEmpty && market == Market.RECEIVE) {
          setState(() {
            if (enabledSellField) {
              FocusScope.of(context).requestFocus(_focusSell);
              controllerAnimationInputSell.reset();
              controllerAnimationInputSell.forward();
            } else {
              controllerAnimationCoinSell.reset();
              controllerAnimationCoinSell.forward();
            }
          });
        } else {
          _openDialogCoinWithBalance(market);
        }
      },
      child: market == Market.RECEIVE
          ? Container(
              child: StreamBuilder<Coin>(
                initialData: swapBloc.receiveCoin,
                stream: swapBloc.outReceiveCoin,
                builder: (BuildContext context, AsyncSnapshot<Coin> snapshot) {
                  if (snapshot.hasData) {
                    return _buildSelectorCoin(snapshot.data);
                  } else {
                    return _buildSelectorCoin(null);
                  }
                },
              ),
            )
          : FadeTransition(
              opacity: animationCoinSell,
              child: StreamBuilder<dynamic>(
                  initialData: swapBloc.sellCoin,
                  stream: swapBloc.outSellCoin,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData && snapshot.data is CoinBalance) {
                      final CoinBalance coinBalance = snapshot.data;
                      currentCoinBalance = coinBalance;
                      return _buildSelectorCoin(coinBalance.coin);
                    } else if (snapshot.hasData && snapshot.data is OrderCoin) {
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
            height: 19,
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
                style: Theme.of(context).textTheme.subtitle,
                maxLines: 1,
              ))),
              Icon(Icons.arrow_drop_down),
            ],
          ),
          const SizedBox(
            height: 12,
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

  Future<void> _openDialogCoinWithBalance(Market market) async {
    if (market == Market.RECEIVE) {
      if (swapBloc.sellCoin != null && swapBloc.sellCoin.coin != null) {
        swapBloc.getBuyCoins(swapBloc.sellCoin.coin);
      }
    }
    final List<SimpleDialogOption> listDialogCoins =
        _createListDialog(context, market, null);

    dialogBloc.dialog = showDialog<List<CoinBalance>>(
        context: context,
        builder: (BuildContext context) {
          return market == Market.SELL
              ? listDialogCoins.isNotEmpty
                  ? SimpleDialog(
                      title: Text(AppLocalizations.of(context).sell),
                      children: listDialogCoins,
                    )
                  : SimpleDialog(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      backgroundColor: Colors.white,
                      title: Column(
                        children: <Widget>[
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).accentColor,
                            size: 48,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            AppLocalizations.of(context).noFunds,
                            style: Theme.of(context)
                                .textTheme
                                .title
                                .copyWith(color: Theme.of(context).accentColor),
                          ),
                          const SizedBox(
                            height: 16,
                          )
                        ],
                      ),
                      children: <Widget>[
                        Text(AppLocalizations.of(context).noFundsDetected,
                            style: Theme.of(context).textTheme.body1.copyWith(
                                color: Theme.of(context).primaryColor)),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: PrimaryButton(
                                text: AppLocalizations.of(context).goToPorfolio,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  mainBloc.setCurrentIndexTab(0);
                                },
                                backgroundColor: Theme.of(context).accentColor,
                                isDarkMode: false,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    )
              : StreamBuilder<List<OrderCoin>>(
                  initialData: swapBloc.orderCoins,
                  stream: swapBloc.outListOrderCoin,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<OrderCoin>> snapshot) {
                    bool orderHasAsks = false;
                    if (snapshot.hasData && snapshot.data.isNotEmpty) {
                      for (OrderCoin orderbook in snapshot.data) {
                        if (orderbook.orderbook.asks.isNotEmpty) {
                          orderHasAsks = true;
                        }
                      }
                      if (orderHasAsks) {
                        return SimpleDialog(
                          title:
                              Text(AppLocalizations.of(context).receiveLower),
                          children:
                              _createListDialog(context, market, snapshot.data),
                        );
                      } else {
                        return DialogLooking(
                          noOrderFind: () {
                            dialogBloc.dialog = showDialog<List<CoinBalance>>(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    title: Text(AppLocalizations.of(context)
                                        .receiveLower),
                                    children: _createListDialog(
                                        context, market, snapshot.data),
                                  );
                                });
                          },
                        );
                      }
                    } else {
                      return const DialogLooking();
                    }
                  },
                );
        }).then((_) {
      dialogBloc.dialog = null;
    });
  }

  List<SimpleDialogOption> _createListDialog(
      BuildContext context, Market market, List<OrderCoin> orderbooks) {
    final List<SimpleDialogOption> listDialog = <SimpleDialogOption>[];
    _controllerAmountSell.text =
        _controllerAmountSell.text.replaceAll(',', '.');
    _controllerAmountReceive.text =
        _controllerAmountReceive.text.replaceAll(',', '.');

    if (orderbooks != null && market == Market.RECEIVE) {
      for (OrderCoin orderbook in orderbooks) {
        SimpleDialogOption dialogItem;
        if (orderbook.coinBase.abbr != swapBloc.sellCoin.coin.abbr) {
          final bool isOrderAvailable = orderbook.coinBase.abbr !=
                  swapBloc.sellCoin.coin.abbr &&
              double.parse(orderbook
                      .getBuyAmount(double.parse(_controllerAmountSell.text))) >
                  0;
          print('----getBuyAmount----' +
              orderbook.getBuyAmount(double.parse(_controllerAmountSell.text)));
          dialogItem = SimpleDialogOption(
            onPressed: () async {
              _controllerAmountReceive.clear();
              setState(() {
                swapBloc.enabledReceiveField = false;
                _noOrderFound = false;
              });
              swapBloc.updateReceiveCoin(orderbook.coinBase);
              _controllerAmountReceive.text = '';
              if (timerGetOrderbook != null) {
                timerGetOrderbook.cancel();
              }

              _lookingForOrder();

              Navigator.pop(context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      'assets/${orderbook.coinBase.abbr.toLowerCase()}.png',
                    )),
                Expanded(
                  child: Container(),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    isOrderAvailable
                        ? Text(orderbook.getBuyAmount(
                            double.parse(_controllerAmountSell.text)))
                        : Text(
                            AppLocalizations.of(context).noOrderAvailable,
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(color: Theme.of(context).cursorColor),
                          ),
                    const SizedBox(
                      width: 4,
                    ),
                    isOrderAvailable
                        ? Text(
                            orderbook.coinBase.abbr,
                            style: Theme.of(context).textTheme.caption,
                          )
                        : Container()
                  ],
                )
              ],
            ),
          );
        }
        if (dialogItem != null) {
          listDialog.add(dialogItem);
        }
      }
    } else if (market == Market.SELL) {
      for (CoinBalance coin in coinsBloc.coinBalance) {
        if (double.parse(coin.balance.getBalance()) > 0) {
          final SimpleDialogOption dialogItem = SimpleDialogOption(
            onPressed: () {
              swapBloc.updateBuyCoin(null);
              swapBloc.updateReceiveCoin(null);
              swapBloc.setTimeout(true);
              _controllerAmountReceive.clear();
              setState(() {
                currentCoinBalance = coin;
                final String tmp = _controllerAmountSell.text;
                _controllerAmountSell.text = '';
                _controllerAmountSell.text = tmp;
                _controllerAmountReceive.text = '';
                enabledSellField = true;
              });
              swapBloc.updateSellCoin(coin);
              swapBloc.updateBuyCoin(null);

              Navigator.pop(context);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 30,
                    width: 30,
                    child: Image.asset(
                      'assets/${coin.coin.abbr.toLowerCase()}.png',
                    )),
                Expanded(
                  child: Container(),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(coin.balance.getBalance()),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      coin.coin.abbr,
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                )
              ],
            ),
          );
          listDialog.add(dialogItem);
        }
      }
    }

    return listDialog;
  }

  bool _checkValueMin() {
    _controllerAmountSell.text =
        _controllerAmountSell.text.replaceAll(',', '.');
    _controllerAmountReceive.text =
        _controllerAmountReceive.text.replaceAll(',', '.');

    if (_controllerAmountSell.text != null &&
        _controllerAmountSell.text.isNotEmpty &&
        double.parse(_controllerAmountSell.text) < 3 &&
        swapBloc.sellCoin.coin.abbr == 'QTUM') {
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(AppLocalizations.of(context)
            .minValue(swapBloc.sellCoin.coin.abbr, 3)),
      ));
      return false;
    } else if (_controllerAmountSell.text != null &&
        _controllerAmountSell.text.isNotEmpty &&
        double.parse(_controllerAmountSell.text) < 0.00777) {
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(AppLocalizations.of(context)
            .minValue(swapBloc.sellCoin.coin.abbr, 0.00777)),
      ));
      return false;
    } else if (_controllerAmountReceive.text != null &&
        _controllerAmountReceive.text.isNotEmpty &&
        double.parse(_controllerAmountReceive.text) < 0.00777) {
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(AppLocalizations.of(context)
            .minValueBuy(swapBloc.receiveCoin.abbr, 0.00777)),
      ));
      return false;
    } else {
      return true;
    }
  }

  void _confirmSwap(BuildContext mContext) {
    _controllerAmountSell.text =
        _controllerAmountSell.text.replaceAll(',', '.');
    _controllerAmountReceive.text =
        _controllerAmountReceive.text.replaceAll(',', '.');

    if (mainBloc.isNetworkOffline) {
      Scaffold.of(mContext).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).errorColor,
        content: Text(AppLocalizations.of(context).noInternet),
      ));
    }
    if (_checkValueMin() && !mainBloc.isNetworkOffline) {
      setState(() {
        _noOrderFound = false;
      });
      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => SwapConfirmation(
                  orderSuccess: () {
                    dialogBloc.dialog = showDialog<dynamic>(
                            builder: (BuildContext context) {
                              return SimpleDialog(
                                title: Text(
                                    AppLocalizations.of(context).orderCreated),
                                contentPadding: const EdgeInsets.all(24),
                                children: <Widget>[
                                  Text(AppLocalizations.of(context)
                                      .orderCreatedInfo),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  PrimaryButton(
                                    text: AppLocalizations.of(context)
                                        .showMyOrders,
                                    onPressed: () {
                                      swapBloc.setIndexTabDex(1);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  SecondaryButton(
                                    text: AppLocalizations.of(context).close,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            },
                            context: context)
                        .then((dynamic _) {
                      dialogBloc.dialog = null;
                    });
                  },
                  swapStatus: swapBloc.enabledReceiveField
                      ? SwapStatus.SELL
                      : SwapStatus.BUY,
                  amountToSell: _controllerAmountSell.text.replaceAll(',', '.'),
                  amountToBuy:
                      _controllerAmountReceive.text.replaceAll(',', '.'),
                )),
      ).then((dynamic _) {
        _controllerAmountReceive.clear();
        _controllerAmountSell.clear();
      });
    }
  }

  Future<void> _lookingForOrder() async {
    _controllerAmountSell.text =
        _controllerAmountSell.text.replaceAll(',', '.');
    _controllerAmountReceive.text =
        _controllerAmountReceive.text.replaceAll(',', '.');

    swapBloc.setTimeout(false);

    final double amount = await swapBloc.setReceiveAmount(
        swapBloc.receiveCoin, _controllerAmountSell.text);
    swapBloc.setTimeout(true);

    if (amount == 0) {
      setState(() {
        _controllerAmountReceive.text = swapBloc.amountReceive.toString();
      });
      if (swapBloc.amountReceive == 0) {
        setState(() {
          _noOrderFound = true;
          _controllerAmountReceive.text = '';
          if (swapBloc.receiveCoin != null) {
            swapBloc.enabledReceiveField = true;
            FocusScope.of(context).requestFocus(_focusReceive);
          }
        });
      }
    } else {
      _checkMaxVolume();
    }
  }
}

enum Market {
  SELL,
  RECEIVE,
}

class DialogLooking extends StatefulWidget {
  const DialogLooking({Key key, this.noOrderFind}) : super(key: key);

  final Function noOrderFind;

  @override
  _DialogLookingState createState() => _DialogLookingState();
}

class _DialogLookingState extends State<DialogLooking> {
  Timer timerGetOrderbook;

  @override
  void initState() {
    const int timerEnd = 10;
    int timerCurrent = 0;

    timerGetOrderbook = Timer.periodic(const Duration(seconds: 5), (_) {
      timerCurrent += 5;
      if (timerCurrent >= timerEnd) {
        timerGetOrderbook.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.noOrderFind();
      } else {
        swapBloc.getBuyCoins(swapBloc.sellCoin.coin);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (timerGetOrderbook != null) {
      timerGetOrderbook.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(
              width: 16,
            ),
            Text(
              AppLocalizations.of(context).loadingOrderbook,
              style: Theme.of(context).textTheme.body1,
            )
          ],
        ),
      ),
    );
  }
}

class ExchangeRate extends StatefulWidget {
  @override
  _ExchangeRateState createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderCoin>(
        initialData: swapBloc.orderCoin,
        stream: swapBloc.outOrderCoin,
        builder: (BuildContext context, AsyncSnapshot<OrderCoin> snapshot) {
          if (snapshot.hasData && snapshot.data.bestPrice > 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).bestAvailableRate,
                    style: Theme.of(context)
                        .textTheme
                        .body2
                        .copyWith(fontSize: 12),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        swapBloc.getExchangeRate(),
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        swapBloc.getExchangeRateUSD(),
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ],
                  )
                ],
              ),
            );
          } else {
            return Container(
              height: 84,
            );
          }
        });
  }
}
