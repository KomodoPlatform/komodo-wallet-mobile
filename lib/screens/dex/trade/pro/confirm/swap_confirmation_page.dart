import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../../blocs/orders_bloc.dart';
import '../../../../../blocs/swap_bloc.dart';
import '../../../../../localizations.dart';
import '../../../../../app_config/app_config.dart';
import '../../../../../model/cex_provider.dart';
import '../../../../../model/coin.dart';
import '../../../../../model/error_string.dart';
import '../../../../../model/get_buy.dart';
import '../../../../../model/recent_swaps.dart';
import '../../../../../model/swap.dart';
import '../../../../authentification/lock_screen.dart';
import '../../../../dex/orders/swap/swap_detail_page.dart';
import '../../../../dex/trade/build_detailed_fees.dart';
import '../../../../dex/trade/pro/confirm/min_volume_control.dart';
import '../../../../dex/trade/pro/confirm/order_created_popup.dart';
import '../../../../dex/trade/pro/confirm/protection_control.dart';
import '../../../../dex/trade/pro/create/trade_form.dart';
import '../../../../dex/trade/pro/evaluation.dart';
import '../../../../dex/trade/pro/exchange_rate.dart';
import '../../../../../services/mm_service.dart';
import '../../../../../utils/log.dart';
import '../../../../../utils/utils.dart';
import 'package:provider/provider.dart';

class SwapConfirmationPage extends StatefulWidget {
  @override
  _SwapConfirmationPageState createState() => _SwapConfirmationPageState();
}

class _SwapConfirmationPageState extends State<SwapConfirmationPage> {
  CexProvider _cexProvider;
  bool _inProgress = false;
  String _minVolume;
  bool _isMinVolumeValid = true;
  BuyOrderType _buyOrderType = BuyOrderType.FillOrKill;
  LinkedHashMap _batteryData;
  Timer _batteryTimer;
  ProtectionSettings _protectionSettings = ProtectionSettings(
    requiredConfirmations:
        swapBloc.receiveCoinBalance.coin.requiredConfirmations,
    requiresNotarization:
        swapBloc.receiveCoinBalance.coin.requiresNotarization ?? false,
  );

  @override
  void initState() {
    super.initState();

    _batteryTimer = Timer.periodic(Duration(seconds: 1), _checkBattery);
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cexProvider ??= Provider.of<CexProvider>(context);

    return LockScreen(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).swapDetailTitle),
        ),
        body: !_hasData()
            ? SizedBox()
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 24),
                    _buildCoinSwapDetail(),
                    _buildTestCoinWarning(),
                    _buildBatteryWarning(),
                    _buildMobileDataWarning(),
                    SizedBox(height: 24),
                    _buildFees(),
                    SizedBox(height: 24),
                    _buildExchangeRate(),
                    SizedBox(height: 24),
                    _buildEvaluation(),
                    SizedBox(height: 24),
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
                          base: swapBloc.sellCoinBalance.coin.abbr,
                          rel: swapBloc.receiveCoinBalance.coin.abbr,
                          price: swapBloc.amountReceive / swapBloc.amountSell,
                          onChange: (String value, bool isValid) {
                            setState(() {
                              _minVolume = value;
                              _isMinVolumeValid = isValid;
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

  Future<void> _checkBattery(dynamic _) async {
    LinkedHashMap battery;
    try {
      battery = await MMService.nativeC.invokeMethod('battery');
    } catch (e) {
      Log('swap_confirmaiton_page]', '_checkBattery: $e');
    }

    if (mounted)
      setState(() {
        _batteryData = battery;
      });
  }

  bool _isBatteryCritical() {
    if (_batteryData == null || _batteryData['level'] == null) return false;
    if (_batteryData['charging']) return false;

    return (_batteryData['level'] * 100).round() <=
        appConfig.batteryLevelCritical;
  }

  bool _hasData() {
    return swapBloc.sellCoinBalance != null &&
        swapBloc.receiveCoinBalance != null;
  }

  Widget _buildEvaluation() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            )),
          ),
          child: Evaluation()),
    );
  }

  Widget _buildExchangeRate() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
              color: Theme.of(context).highlightColor,
            )),
          ),
          child: ExchangeRate()),
    );
  }

  Widget _buildFees() {
    return Container(
      padding: EdgeInsets.fromLTRB(26, 0, 26, 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            color: Theme.of(context).highlightColor,
          ),
        )),
        child: BuildDetailedFees(preimage: swapBloc.tradePreimage),
      ),
    );
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
    final String amountSell = cutTrailingZeros(
        swapBloc.amountSell.toStringAsFixed(appConfig.tradeFormPrecision));
    final String amountReceive = cutTrailingZeros(
        swapBloc.amountReceive.toStringAsFixed(appConfig.tradeFormPrecision));

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
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withOpacity(0.05)
                  : Colors.white.withOpacity(0.15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(AppLocalizations.of(context).sell,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w300,
                          )),
                  Text(
                    '$amountSell ${swapBloc.sellCoinBalance.coin.abbr}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  _buildSellFiat(),
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
            clipBehavior: Clip.none,
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
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black.withOpacity(0.05)
                        : Colors.white.withOpacity(0.15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildReceiveFiat(),
                        Text(
                          '$amountReceive ${swapBloc.receiveCoinBalance.coin.abbr}',
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w300,
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
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: SvgPicture.asset(
                            Theme.of(context).brightness == Brightness.light
                                ? 'assets/svg_light/icon_swap.svg'
                                : 'assets/svg/icon_swap.svg')),
                  ))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDataWarning() {
    return FutureBuilder(
      future: Connectivity().checkConnectivity(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        if (snapshot.data == ConnectivityResult.wifi) return SizedBox();

        return _buildWarning(
          text:
              AppLocalizations.of(context).mobileDataWarning(appConfig.appName),
          iconData: Icons.network_check,
        );
      },
    );
  }

  Widget _buildBatteryWarning() {
    if (_batteryData == null) return SizedBox();

    final double level = _batteryData['level'];
    final bool isInLowPowerMode = _batteryData['lowPowerMode'];
    final bool isCharging = _batteryData['charging'];

    if (isCharging) return SizedBox();

    String message = '';
    Color color;

    if (_isBatteryCritical()) {
      message = AppLocalizations.of(context)
          .batteryCriticalError('${appConfig.batteryLevelCritical}');
      color = Theme.of(context).errorColor;
    } else if (level < appConfig.batteryLevelLow / 100) {
      message = AppLocalizations.of(context)
          .batteryLowWarning('${appConfig.batteryLevelLow}');
    } else if (isInLowPowerMode) {
      message = AppLocalizations.of(context).batterySavingWarning;
    }

    if (message.isEmpty) return SizedBox();

    return _buildWarning(
      text: message,
      color: color,
      iconData: Icons.battery_alert,
    );
  }

  Widget _buildTestCoinWarning() {
    final Coin coinSell = swapBloc.sellCoinBalance.coin;
    final Coin coinBuy = swapBloc.receiveCoinBalance.coin;

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
      return _buildWarning(text: warningMessage);
    }
  }

  Widget _buildWarning({String text, IconData iconData, Color color}) {
    color ??= (Theme.of(context).brightness == Brightness.light
            ? Colors.yellow[700]
            : Colors.yellow[100])
        .withAlpha(200);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            if (iconData != null) ...{
              Icon(iconData, size: 16, color: Theme.of(context).primaryColor),
              SizedBox(width: 10),
            },
            Expanded(
              child: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellFiat() {
    final double sellAmtUsd = swapBloc.amountSell.toDouble() *
        _cexProvider.getUsdPrice(swapBloc.sellCoinBalance.coin.abbr);
    if (sellAmtUsd == 0) return SizedBox();

    return Text(
      _cexProvider.convert(sellAmtUsd),
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildReceiveFiat() {
    final double receiveeAmtUsd = swapBloc.amountReceive.toDouble() *
        _cexProvider.getUsdPrice(swapBloc.receiveCoinBalance.coin.abbr);
    if (receiveeAmtUsd == 0) return SizedBox();

    return Text(
      _cexProvider.convert(receiveeAmtUsd),
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildInfoSwap() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
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
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            AppLocalizations.of(context).infoTrade2,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
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
        _inProgress || !_isMinVolumeValid || _isBatteryCritical();

    return Builder(builder: (context) {
      return Column(
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          _inProgress
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  key: const Key('confirm-swap-button'),
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child:
                      Text(AppLocalizations.of(context).confirm.toUpperCase()),
                ),
          const SizedBox(
            height: 8,
          ),
          TextButton(
            key: const Key('cancel-swap-button'),
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(AppLocalizations.of(context).cancel.toUpperCase()),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                myAmount: cutTrailingZeros(swapBloc.amountSell
                    .toStringAsFixed(appConfig.tradeFormPrecision)),
                otherAmount: cutTrailingZeros(swapBloc.amountReceive
                    .toStringAsFixed(appConfig.tradeFormPrecision)),
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
    } else {
      Navigator.of(context).pop();
      showOrderCreatedDialog(context);
    }

    tradeForm.reset();
  }
}
