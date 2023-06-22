import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../../blocs/coins_bloc.dart';
import '../../../../../blocs/orders_bloc.dart';
import '../../../../../localizations.dart';
import '../../../../../app_config/app_config.dart';
import '../../../../../../model/cex_provider.dart';
import '../../../../../model/coin.dart';
import '../../../../../model/error_string.dart';
import '../../../../../model/get_buy.dart';
import '../../../../../model/recent_swaps.dart';
import '../../../../../model/swap.dart';
import '../../../../../model/swap_constructor_provider.dart';
import '../../../../authentification/lock_screen.dart';
import '../../../../dex/orders/swap/swap_detail_page.dart';
import '../../../../dex/trade/pro/confirm/protection_control.dart';
import '../../../../dex/trade/simple/build_detailed_fees_simple.dart';
import '../../../../dex/trade/simple/exchange_rate_simple.dart';
import '../../../../../services/mm_service.dart';
import '../../../../../utils/log.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/auto_scroll_text.dart';
import 'package:provider/provider.dart';

class SwapConfirmationPageSimple extends StatefulWidget {
  @override
  _SwapConfirmationPageSimpleState createState() =>
      _SwapConfirmationPageSimpleState();
}

class _SwapConfirmationPageSimpleState
    extends State<SwapConfirmationPageSimple> {
  ConstructorProvider _constrProvider;
  CexProvider _cexProvider;
  bool _inProgress = false;
  LinkedHashMap _batteryData;
  Timer _batteryTimer;
  ProtectionSettings _protectionSettings;
  Coin _sellCoin;
  Coin _buyCoin;
  double _sellAmtUsd;

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
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    _sellCoin ??= coinsBloc.getCoinByAbbr(_constrProvider.sellCoin);
    _buyCoin ??= coinsBloc.getCoinByAbbr(_constrProvider.buyCoin);

    _protectionSettings ??= ProtectionSettings(
      requiredConfirmations: _buyCoin.requiredConfirmations,
      requiresNotarization: _buyCoin.requiresNotarization ?? false,
    );

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
                    SizedBox(height: 12),
                    _buildCoinSwapDetail(),
                    _buildTestCoinWarning(),
                    _buildBatteryWarning(),
                    _buildMobileDataWarning(),
                    _buildTradeWarning(),
                    SizedBox(height: 12),
                    _buildExchangeRate(),
                    SizedBox(height: 12),
                    _buildFees(),
                    SizedBox(height: 12),
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
      Log('swap_confirmaiton_page_simple]', '_checkBattery: $e');
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
    return _constrProvider.sellCoin != null && _constrProvider.buyCoin != null;
  }

  Widget _buildExchangeRate() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
              color: Theme.of(context).highlightColor,
            )),
          ),
          child: ExchangeRateSimple()),
    );
  }

  Widget _buildFees() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            color: Theme.of(context).highlightColor,
          ),
        )),
        child: BuildDetailedFeesSimple(preimage: _constrProvider.preimage),
      ),
    );
  }

  Widget _buildCoinSwapDetail() {
    final String amountSell = cutTrailingZeros(_constrProvider.sellAmount
        .toStringAsFixed(appConfig.tradeFormPrecision));
    final String amountReceive = cutTrailingZeros(_constrProvider.buyAmount
        .toStringAsFixed(appConfig.tradeFormPrecision));

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      Text(AppLocalizations.of(context).send,
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w100,
                              )),
                      SizedBox(height: 8),
                      AutoScrollText(
                        text: '$amountSell ${_constrProvider.sellCoin}',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(height: 8),
                      _buildSellFiat(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            SizedBox(height: 4),
                            AutoScrollText(
                              text: '$amountReceive ${_constrProvider.buyCoin}',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            SizedBox(height: 8),
                            Text(AppLocalizations.of(context).receive,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.w100,
                                    ))
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SvgPicture.asset(
                Theme.of(context).brightness == Brightness.light
                    ? 'assets/svg_light/icon_swap.svg'
                    : 'assets/svg/icon_swap.svg'),
          ),
        ),
      ],
    );
  }

  Widget _buildTradeWarning() {
    if (_constrProvider.warning == null) return SizedBox();

    return _buildWarning(
      text: _constrProvider.warning,
      iconData: Icons.notification_important,
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
    String warningMessage;
    if (_sellCoin.testCoin && !_buyCoin.testCoin) {
      warningMessage = AppLocalizations.of(context).sellTestCoinWarning;
    }
    if (_buyCoin.testCoin && !_sellCoin.testCoin) {
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
      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
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
    setState(() {
      _sellAmtUsd = _constrProvider.sellAmount.toDouble() *
          _cexProvider.getUsdPrice(_constrProvider.sellCoin);
    });

    if (_sellAmtUsd == 0) return SizedBox();

    return Text(
      _cexProvider.convert(_sellAmtUsd),
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildReceiveFiat() {
    final double receiveeAmtUsd = _constrProvider.buyAmount.toDouble() *
        _cexProvider.getUsdPrice(_constrProvider.buyCoin);
    if (receiveeAmtUsd == 0) return SizedBox();

    Color color;
    if (_sellAmtUsd > 0) {
      if (receiveeAmtUsd > _sellAmtUsd) color = Colors.green;
      if (receiveeAmtUsd < _sellAmtUsd) color = Colors.orange;
    }

    return Text(
      _cexProvider.convert(receiveeAmtUsd),
      style: Theme.of(context).textTheme.caption.copyWith(color: color),
    );
  }

  Widget _buildInfoSwap() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
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
      ),
    );
  }

  Widget _buildButtons() {
    final bool disabled = _inProgress || _isBatteryCritical();

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 56),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(AppLocalizations.of(context).back.toUpperCase()),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _inProgress
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    key: const Key('confirm-simple-swap-button'),
                    onPressed: disabled
                        ? null
                        : () async {
                            setState(() => _inProgress = true);

                            await _constrProvider.makeSwap(
                              buyOrderType: BuyOrderType.FillOrKill,
                              protectionSettings: _protectionSettings,
                              onSuccess: (dynamic re) =>
                                  _goToNextScreen(context, re),
                              onError: (dynamic err) =>
                                  _catchErrorSwap(context, err),
                            );

                            setState(() => _inProgress = false);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context).startSwap),
                  ),
          ),
        ],
      ),
    );
  }

  void _catchErrorSwap(BuildContext context, ErrorString error) {
    String timeSecondeLeft = error.error;
    Log('swap_confirmation_page_simple', timeSecondeLeft);
    timeSecondeLeft = timeSecondeLeft.substring(
        timeSecondeLeft.lastIndexOf(' '), timeSecondeLeft.length);
    Log('swap_confirmation_page_simple', timeSecondeLeft);
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

    final swapEgg = Swap(
        status: Status.ORDER_MATCHING,
        result: MmSwap(
          uuid: response.result.uuid,
          myInfo: SwapMyInfo(
              myAmount: cutTrailingZeros(_constrProvider.sellAmount
                  .toStringAsFixed(appConfig.tradeFormPrecision)),
              otherAmount: cutTrailingZeros(_constrProvider.buyAmount
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

    _constrProvider.reset();
  }
}
