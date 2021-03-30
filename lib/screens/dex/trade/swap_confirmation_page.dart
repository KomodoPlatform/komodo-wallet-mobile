import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_buy.dart';
import 'package:komodo_dex/model/get_setprice.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/swap_detail_page.dart';
import 'package:komodo_dex/screens/dex/trade/exchange_rate.dart';
import 'package:komodo_dex/screens/dex/trade/min_volume_control.dart';
import 'package:komodo_dex/screens/dex/trade/protection_control.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/widgets/sounds_explanation_dialog.dart';

enum SwapStatus { BUY, SELL }

class SwapConfirmation extends StatefulWidget {
  const SwapConfirmation(
      {@required this.bestPrice,
      @required this.coinBase,
      @required this.coinRel,
      @required this.amountToSell,
      @required this.amountToBuy,
      @required this.swapStatus,
      this.orderSuccess,
      this.order});

  final SwapStatus swapStatus;
  final String amountToSell;
  final String amountToBuy;
  final Function orderSuccess;
  final String bestPrice;
  final Coin coinBase;
  final Coin coinRel;
  final Ask order;

  @override
  _SwapConfirmationState createState() => _SwapConfirmationState();
}

class _SwapConfirmationState extends State<SwapConfirmation> {
  bool _isSwapMaking = false;
  String _minVolume;
  BuyOrderType _buyOrderType = BuyOrderType.FillOrKill;
  ProtectionSettings _protectionSettings;

  @override
  void initState() {
    _protectionSettings = ProtectionSettings(
      requiredConfirmations: widget.coinBase.requiredConfirmations,
      requiresNotarization: widget.coinBase.requiresNotarization ?? false,
    );
    super.initState();
  }

  @override
  void dispose() {
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);
    swapBloc.setEnabledSellField(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: WillPopScope(
        onWillPop: () {
          _resetSwapPage();
          Navigator.pop(context);
          return;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                _resetSwapPage();
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back),
            ),
            title: Text(AppLocalizations.of(context).swapDetailTitle),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 24),
                _buildCoinSwapDetail(),
                _buildTestCoinWarning(),
                ExchangeRate(),
                const SizedBox(height: 8),
                ProtectionControl(
                  coin: widget.coinBase,
                  onChange: (ProtectionSettings settings) {
                    setState(() {
                      _protectionSettings = settings;
                    });
                  },
                ),
                if (widget.swapStatus == SwapStatus.SELL)
                  MinVolumeControl(
                      coin: widget.coinRel.abbr,
                      validator: _validateMinVolume,
                      onChange: (String value) {
                        setState(() {
                          _minVolume = value;
                        });
                      }),
                if (widget.swapStatus == SwapStatus.BUY) _buildBuyOrderType(),
                const SizedBox(height: 8),
                _buildButtons(),
                _buildInfoSwap()
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _validateMinVolume(String value) {
    if (value == null) return null;

    final double minVolumeValue = double.tryParse(value);
    final double minVolumeDefault =
        swapBloc.minVolumeDefault(widget.coinRel.abbr);
    final double amountToSell = double.tryParse(widget.amountToSell);

    if (minVolumeValue == null) {
      return AppLocalizations.of(context).nonNumericInput;
    } else if (minVolumeValue < minVolumeDefault) {
      return AppLocalizations.of(context)
          .minVolumeInput(minVolumeDefault, widget.coinRel.abbr);
    } else if (amountToSell != null && minVolumeValue > amountToSell) {
      return AppLocalizations.of(context).minVolumeIsTDH;
    } else {
      return null;
    }
  }

  Widget _buildBuyOrderType() {
    return InkWell(
      onTap: () {
        setState(() {
          _buyOrderType = _buyOrderType == BuyOrderType.FillOrKill
              ? BuyOrderType.GoodTillCancelled
              : BuyOrderType.FillOrKill;
        });
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 8, 30, 8),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Icon(
                  _buyOrderType == BuyOrderType.GoodTillCancelled
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).buyOrderType,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetSwapPage() {
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);
    swapBloc.enabledReceiveField = false;
  }

  Widget _buildCoinSwapDetail() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            child: Container(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: 30,
                top: 20,
              ),
              width: double.infinity,
              color: settingsBloc.switchTheme?  Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${widget.amountToSell} ${widget?.coinRel?.abbr}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(AppLocalizations.of(context).sell,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.w100,
                          ))
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
                child: Container(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 20,
                      top: 26,
                    ),
                    width: double.infinity,
                    color: settingsBloc.switchTheme?  Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${widget.amountToBuy} ${widget.coinBase.abbr}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text(
                            AppLocalizations.of(context)
                                    .receive
                                    .substring(0, 1) +
                                AppLocalizations.of(context)
                                    .receive
                                    .toLowerCase()
                                    .substring(1),
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.w100,
                                    ))
                      ],
                    )),
              ),
              Positioned(
                  left: (MediaQuery.of(context).size.width / 2) - 70,
                  top: -22,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 4),
                        color: Theme.of(context).backgroundColor,
                        child: SvgPicture.asset(settingsBloc.switchTheme?  'assets/svg_light/icon_swap.svg' :  'assets/svg/icon_swap.svg')),
                  ))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestCoinWarning() {
    final Coin coinSell = widget.coinRel;
    final Coin coinBuy = widget.coinBase;

    String warningMessage;
    if (coinSell.testCoin && !coinBuy.testCoin) {
      warningMessage = AppLocalizations.of(context).sellTestCoinWarning;
    }
    if (coinBuy.testCoin && !coinSell.testCoin) {
      warningMessage = AppLocalizations.of(context).buyTestCoinWarning;
    }

    if (warningMessage == null) {
      return SizedBox();
    } else {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.yellow[100].withAlpha(200),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.all(8),
          child: Text(
            warningMessage,
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: Theme.of(context).primaryColor),
          ),
        ),
      );
    }
  }

  Widget _buildInfoSwap() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  color: Theme.of(context).backgroundColor,
                  height: 32,
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 32),
                      child: Column(
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).infoTrade1,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            AppLocalizations.of(context).infoTrade2,
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
                left: 32,
                top: 8,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(52)),
                  child: Container(
                    height: 52,
                    width: 52,
                    color: Theme.of(context).backgroundColor,
                    child: Icon(
                      Icons.info,
                      size: 48,
                    ),
                  ),
                )),
          ],
        )
      ],
    );
  }

  Widget _buildButtons() {
    final bool disabled =
        _isSwapMaking || _validateMinVolume(_minVolume) != null;

    return Builder(builder: (BuildContext context) {
      return Column(
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          _isSwapMaking
              ? const CircularProgressIndicator()
              : RaisedButton(
                  key: const Key('confirm-swap-button'),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child:
                      Text(AppLocalizations.of(context).confirm.toUpperCase()),
                  onPressed: disabled ? null : () => _makeASwap(context),
                ),
          const SizedBox(
            height: 8,
          ),
          FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 56),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Text(AppLocalizations.of(context).cancel.toUpperCase()),
            onPressed: () {
              swapBloc.updateSellCoin(null);
              swapBloc.updateBuyCoin(null);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  Future<void> _makeASwap(BuildContext mContext) async {
    Log('swap_confirmation_page:315', '_makeASwap] Starting a swap…');
    setState(() {
      _isSwapMaking = true;
    });

    final Coin coinBase = widget.coinBase;
    final Coin coinRel = widget.coinRel;
    String price = '0';

    if (widget.order != null) {
      price = widget.order.price;
    }

    final String amountToSell = widget.amountToSell.replaceAll(',', '.');
    final Decimal satoshi = Decimal.parse('100000000');
    final Decimal satoshiSellAmount =
        Decimal.parse(widget.amountToSell.replaceAll(',', '.')) * satoshi;
    Decimal satoshiBuyAmount = price != '0'
        ? Decimal.parse((Decimal.parse(amountToSell) / Decimal.parse(price))
                .toStringAsFixed(8)) *
            satoshi
        : Decimal.parse(Decimal.parse(widget.amountToBuy).toStringAsFixed(8)) *
            satoshi;
    final Decimal satoshiPrice = price != '0'
        ? Decimal.parse(Decimal.parse(price).toStringAsFixed(8)) * satoshi
        : Decimal.parse(Decimal.parse(widget.bestPrice).toStringAsFixed(8)) *
            satoshi;

    //if the desired sellamount != calculated sellamount this loop fixes the precision errors caused by the above division
    //this is considered a dirty quickfix until a final decision is made ref. num handling - likely should follow @ArtemGr's
    //advice ref. utilizing rational datatype IF we need divisions. We do assume sellamount slightly > calculated_sell_amount isnt an issue
    //since swap is going to match - the other way around its problematic
    //this code needs a full refactor
    while (price != '0' &&
        Decimal.parse((satoshiBuyAmount * satoshiPrice / satoshi)
                .toStringAsFixed(0)) <
            satoshiSellAmount) {
      satoshiBuyAmount += Decimal.parse('1');
    }

    if (widget.swapStatus == SwapStatus.BUY) {
      final dynamic re = await MM.postBuy(
          mmSe.client,
          GetBuySell(
            base: coinBase.abbr,
            rel: coinRel.abbr,
            volume: (satoshiBuyAmount / satoshi).toString(),
            max: swapBloc.isMaxActive,
            price: (satoshiPrice / satoshi).toString(),
            orderType: _buyOrderType,
            baseNota: _protectionSettings.requiresNotarization,
            baseConfs: _protectionSettings.requiredConfirmations,
          ));
      if (re is BuyResponse) {
        _goToNextScreen(mContext, re, amountToSell, satoshiBuyAmount / satoshi);
      } else {
        _catchErrorSwap(mContext, re);
      }
    } else if (widget.swapStatus == SwapStatus.SELL) {
      MM
          .postSetPrice(
              mmSe.client,
              GetSetPrice(
                base: coinRel.abbr,
                rel: coinBase.abbr,
                cancelPrevious: false,
                max: swapBloc.isMaxActive,
                volume: amountToSell,
                minVolume: double.tryParse(_minVolume ?? ''),
                price: Decimal.parse(widget.bestPrice).toString(),
                relNota: _protectionSettings.requiresNotarization,
                relConfs: _protectionSettings.requiredConfirmations,
              ))
          .then<dynamic>((dynamic onValue) => onValue is SetPriceResponse
              ? _goToNextScreen(
                  mContext,
                  onValue,
                  amountToSell,
                  Decimal.parse(
                      Decimal.parse(widget.amountToBuy).toStringAsFixed(8)))
              : throw onValue.error)
          .catchError((dynamic onError) => _catchErrorSwap(mContext, onError));
    }
  }

  void _catchErrorSwap(BuildContext mContext, ErrorString error) {
    setState(() {
      _isSwapMaking = false;
    });
    String timeSecondeLeft = error.error;
    Log('swap_confirmation_page:396', timeSecondeLeft);
    timeSecondeLeft = timeSecondeLeft.substring(
        timeSecondeLeft.lastIndexOf(' '), timeSecondeLeft.length);
    Log('swap_confirmation_page:399', timeSecondeLeft);
    String errorDisplay =
        error.error.substring(error.error.lastIndexOf(r']') + 1).trim();
    if (error.error.contains('is too low, required')) {
      errorDisplay = AppLocalizations.of(context).notEnoughtBalanceForFee;
    }
    Scaffold.of(mContext).showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: Theme.of(context).errorColor,
      content: Text(errorDisplay),
    ));
  }

  void _goToNextScreen(BuildContext mContext, dynamic onValue,
      String amountToSell, Decimal amountToBuy) {
    Log('swap_confirmation_page:414', '_goToNextScreen] swap started…');
    ordersBloc.updateOrdersSwaps();

    if (widget.swapStatus == SwapStatus.BUY) {
      Navigator.pushReplacement<dynamic, dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => SwapDetailPage(
                  swap: Swap(
                      status: Status.ORDER_MATCHING,
                      result: MmSwap(
                        uuid: onValue.result.uuid,
                        myInfo: SwapMyInfo(
                            myAmount: amountToSell.toString(),
                            otherAmount: amountToBuy.toString(),
                            myCoin: onValue.result.rel,
                            otherCoin: onValue.result.base,
                            startedAt: DateTime.now().millisecondsSinceEpoch),
                      )),
                )),
      );
      showSoundsDialog(context);
    } else if (widget.swapStatus == SwapStatus.SELL) {
      Navigator.of(context).pop();
      widget.orderSuccess();
    }
  }
}
