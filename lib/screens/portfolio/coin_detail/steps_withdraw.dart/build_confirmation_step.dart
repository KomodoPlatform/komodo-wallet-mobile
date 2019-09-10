import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/services/api_providers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;

class BuildConfirmationStep extends StatefulWidget {
  const BuildConfirmationStep(
      {Key key,
      this.coinBalance,
      this.amountToPay,
      this.addressToSend,
      this.onCancel,
      this.onNoInternet,
      this.onLoadingStep,
      this.onStepChange,
      this.onError,
      this.onSuccessStep})
      : super(key: key);

  final Function onCancel;
  final Function onNoInternet;
  final Function onLoadingStep;
  final Function(int) onStepChange;
  final Function onError;
  final Function(String) onSuccessStep;
  final CoinBalance coinBalance;
  final String amountToPay;
  final String addressToSend;

  @override
  _BuildConfirmationStepState createState() => _BuildConfirmationStepState();
}

class _BuildConfirmationStepState extends State<BuildConfirmationStep> {
  Future<double> getFee() async {
    try {
      final TradeFee tradeFeeResponse = await ApiProvider().getTradeFee(
          http.Client(), GetTradeFee(coin: widget.coinBalance.coin.abbr));
      return double.parse(tradeFeeResponse.result.amount);
    } catch (e) {
      print(e);
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: getFee(),
        builder: (BuildContext context, AsyncSnapshot<Object> snapshot) {
          final bool isErcCoin =
              widget.coinBalance.coin.swapContractAddress?.isNotEmpty;
          bool notEnoughEth = false;
          bool isEthActive = false;

          double fee = 0;
          double ethfee = 0;
          if (snapshot.hasData && coinsDetailBloc.customFee == null) {
            try {
              fee = snapshot.data;
            } catch (e) {
              print(e);
            }
          }

          if (coinsDetailBloc.customFee != null &&
              widget.coinBalance.coin.type != 'erc') {
            fee = double.parse(coinsDetailBloc.customFee.amount);
          }

          if (coinsDetailBloc.customFee != null &&
              widget.coinBalance.coin.type == 'erc') {
            fee = coinsDetailBloc.customFee.gas *
                double.parse(coinsDetailBloc.customFee.gasPrice);
          }

          double amountToPay = double.parse(widget.amountToPay);
          if (!isErcCoin) {
            amountToPay += fee;
          }
          double amountUserReceive = double.parse(widget.amountToPay);
          final double userBalance =
              double.parse(widget.coinBalance.balance.getBalance());

          if (amountToPay > userBalance) {
            amountUserReceive = userBalance;
          }

          if (userBalance == amountUserReceive) {
            amountToPay = amountUserReceive;
            if (!isErcCoin) {
              amountUserReceive -= fee;
            }
          }

          CoinBalance ethCoin;
          for (CoinBalance coinBalance in coinsBloc.coinBalance) {
            if (coinBalance.coin.abbr == 'ETH') {
              ethCoin = coinBalance;
            }
          }

          isEthActive = !(ethCoin == null);
          ethfee = (Decimal.parse(fee.toString()) / Decimal.parse('1000000000'))
              .toDouble();

          if ((ethCoin != null &&
                  ethfee > double.parse(ethCoin.balance.balance)) ||
              (ethCoin != null &&
                  widget.coinBalance.coin.abbr == 'ETH' &&
                  Decimal.parse(ethfee.toString()) +
                          Decimal.parse(widget.amountToPay) >
                      Decimal.parse(ethCoin.balance.balance))) {
            notEnoughEth = true;
          }

          final bool isButtonActive =
              (widget.coinBalance.coin.swapContractAddress.isEmpty &&
                      amountToPay > 0) ||
                  (amountToPay > 0 && !notEnoughEth && isEthActive);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).youAreSending,
                  style: Theme.of(context).textTheme.subtitle,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      amountToPay.toStringAsFixed(8),
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      widget.coinBalance.coin.abbr,
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '- ',
                      style: Theme.of(context).textTheme.body2,
                    ),
                    Text(
                      !isErcCoin ? fee.toStringAsFixed(8) : ethfee.toString(),
                      style: Theme.of(context).textTheme.body2,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      isErcCoin
                          ? AppLocalizations.of(context).ethFee
                          : AppLocalizations.of(context).networkFee,
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                ),
                widget.coinBalance.coin.swapContractAddress.isNotEmpty &&
                        notEnoughEth &&
                        isEthActive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).notEnoughEth,
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .copyWith(color: Theme.of(context).errorColor),
                          ),
                        ],
                      )
                    : Container(),
                widget.coinBalance.coin.swapContractAddress.isNotEmpty &&
                        !isEthActive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).ethNotActive,
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .copyWith(color: Theme.of(context).errorColor),
                          ),
                        ],
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    height: 1,
                    width: double.infinity,
                    color:
                        Theme.of(context).textSelectionColor.withOpacity(0.4),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      amountUserReceive.toStringAsFixed(8),
                      style: Theme.of(context).textTheme.title,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        widget.coinBalance.coin.abbr,
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  AppLocalizations.of(context).toAddress,
                  style: Theme.of(context).textTheme.subtitle,
                ),
                const SizedBox(
                  height: 24,
                ),
                Container(
                  child: AutoSizeText(
                    widget.addressToSend,
                    style: Theme.of(context).textTheme.body1,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SecondaryButton(
                        text: AppLocalizations.of(context).cancel.toUpperCase(),
                        onPressed: widget.onCancel,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Builder(builder: (BuildContext context) {
                        return PrimaryButton(
                          text: AppLocalizations.of(context)
                              .confirm
                              .toUpperCase(),
                          onPressed: isButtonActive
                              ? () {
                                  _onPressedConfirmWithdraw(amountUserReceive);
                                }
                              : null,
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  Future<void> _onPressedConfirmWithdraw(double sendAmount) async {
    if (mainBloc.isNetworkOffline) {
      widget.onNoInternet();
    } else {
      widget.onLoadingStep();
    }
  }
}
