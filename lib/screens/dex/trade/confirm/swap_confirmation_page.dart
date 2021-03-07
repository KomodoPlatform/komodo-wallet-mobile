import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_buy.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/orders/swap/swap_detail_page.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/min_volume_control.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/protection_control.dart';
import 'package:komodo_dex/screens/dex/trade/create/order_created_popup.dart';
import 'package:komodo_dex/screens/dex/trade/exchange_rate.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/sounds_explanation_dialog.dart';

class SwapConfirmationPage extends StatefulWidget {
  @override
  _SwapConfirmationPageState createState() => _SwapConfirmationPageState();
}

class _SwapConfirmationPageState extends State<SwapConfirmationPage> {
  bool _inProgress = false;
  String _minVolume;
  BuyOrderType _buyOrderType = BuyOrderType.FillOrKill;
  ProtectionSettings _protectionSettings = ProtectionSettings(
    requiredConfirmations:
        swapBloc.receiveCoinBalance.coin.requiredConfirmations,
    requiresNotarization:
        swapBloc.receiveCoinBalance.coin.requiresNotarization ?? false,
  );

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).swapDetailTitle),
        ),
        body: !_hasData()
            ? SizedBox()
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 24),
                    _buildCoinSwapDetail(),
                    ExchangeRate(),
                    const SizedBox(height: 8),
                    ProtectionControl(
                      coin: swapBloc.receiveCoinBalance?.coin,
                      onChange: (ProtectionSettings settings) {
                        setState(() {
                          _protectionSettings = settings;
                        });
                      },
                    ),
                    if (swapBloc.matchingBid == null)
                      MinVolumeControl(
                          coin: swapBloc.sellCoinBalance?.coin?.abbr,
                          validator: _validateMinVolume,
                          onChange: (String value) {
                            setState(() {
                              _minVolume = value;
                            });
                          }),
                    if (swapBloc.matchingBid != null) _buildBuyOrderType(),
                    const SizedBox(height: 8),
                    _buildButtons(),
                    _buildInfoSwap()
                  ],
                ),
              ),
      ),
    );
  }

  bool _hasData() {
    return swapBloc.sellCoinBalance != null &&
        swapBloc.receiveCoinBalance != null;
  }

  String _validateMinVolume(String value) {
    if (value == null) return null;

    final double minVolumeValue = double.tryParse(value);
    final double minVolumeDefault =
        tradeForm.minVolumeDefault(swapBloc.sellCoinBalance.coin.abbr);
    final double amountToSell = swapBloc.amountSell;

    if (minVolumeValue == null) {
      return AppLocalizations.of(context).nonNumericInput;
    } else if (minVolumeValue < minVolumeDefault) {
      return AppLocalizations.of(context)
          .minVolumeInput(minVolumeDefault, swapBloc.sellCoinBalance.coin.abbr);
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
              color: Colors.white.withOpacity(0.15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${swapBloc.amountSell ?? ''} ${swapBloc.sellCoinBalance?.coin?.abbr ?? ''}',
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
                    color: Colors.white.withOpacity(0.15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${swapBloc.amountReceive} ${swapBloc.receiveCoinBalance.coin.abbr}',
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
                        child: SvgPicture.asset('assets/svg/icon_swap.svg')),
                  ))
            ],
          ),
        ),
      ],
    );
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
    final bool disabled = _inProgress || _validateMinVolume(_minVolume) != null;

    return Builder(builder: (BuildContext context) {
      return Column(
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          _inProgress
              ? const CircularProgressIndicator()
              : RaisedButton(
                  key: const Key('confirm-swap-button'),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child:
                      Text(AppLocalizations.of(context).confirm.toUpperCase()),
                  onPressed: disabled
                      ? null
                      : () async {
                          setState(() => _inProgress = true);

                          await tradeForm.makeSwap(
                            buyOrderType: _buyOrderType,
                            protectionSettings: _protectionSettings,
                            minVolume: _minVolume,
                            onSuccess: (dynamic re) =>
                                _goToNextScreen(context, re),
                            onError: (dynamic err) =>
                                _catchErrorSwap(context, err),
                          );

                          setState(() => _inProgress = false);
                        },
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
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  void _catchErrorSwap(BuildContext context, ErrorString error) {
    String timeSecondeLeft = error.error;
    Log('swap_confirmation_page', timeSecondeLeft);
    timeSecondeLeft = timeSecondeLeft.substring(
        timeSecondeLeft.lastIndexOf(' '), timeSecondeLeft.length);
    Log('swap_confirmation_page', timeSecondeLeft);
    String errorDisplay =
        error.error.substring(error.error.lastIndexOf(r']') + 1).trim();
    if (error.error.contains('is too low, required')) {
      errorDisplay = AppLocalizations.of(context).notEnoughtBalanceForFee;
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: Theme.of(context).errorColor,
      content: Text(errorDisplay),
    ));
  }

  void _goToNextScreen(BuildContext context, dynamic response) {
    ordersBloc.updateOrdersSwaps();

    if (swapBloc.matchingBid != null) {
      final swapEgg = Swap(
          status: Status.ORDER_MATCHING,
          result: MmSwap(
            uuid: response.result.uuid,
            myInfo: SwapMyInfo(
                myAmount: cutTrailingZeros(formatPrice(swapBloc.amountSell)),
                otherAmount:
                    cutTrailingZeros(formatPrice(swapBloc.amountReceive)),
                myCoin: response.result.rel,
                otherCoin: response.result.base,
                startedAt: DateTime.now().millisecondsSinceEpoch),
          ));

      Navigator.pushReplacement<dynamic, dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => SwapDetailPage(swap: swapEgg),
        ),
      );

      showSoundsDialog(context);
    } else {
      Navigator.of(context).pop();
      showOrderCreatedDialog(context);
    }

    tradeForm.reset();
  }
}
