import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/screens/dex/trade/get_fee.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';
import 'package:decimal/decimal.dart';

class BuildConfirmationStep extends StatefulWidget {
  const BuildConfirmationStep({
    Key key,
    this.coinBalance,
    this.amountToPay,
    this.addressToSend,
    this.onCancel,
    this.onError,
    this.onNoInternet,
    this.onConfirmPressed,
  }) : super(key: key);

  final Function onCancel;
  final Function onNoInternet;
  final Function onError;
  final Function(WithdrawResponse) onConfirmPressed;
  final CoinBalance coinBalance;
  final String amountToPay;
  final String addressToSend;

  @override
  _BuildConfirmationStepState createState() => _BuildConfirmationStepState();
}

class _BuildConfirmationStepState extends State<BuildConfirmationStep> {
  dynamic withdrawResponse;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Fee fee = Fee();
      if (coinsDetailBloc.customFee != null) {
        if (widget.coinBalance.coin.type == 'erc') {
          fee.type = 'EthGas';
          fee.gas = coinsDetailBloc.customFee.gas;
          fee.gasPrice = coinsDetailBloc.customFee.gasPrice;
        } else {
          fee.type = 'UtxoFixed';
          fee.amount = coinsDetailBloc.customFee.amount;
        }
      }

      ApiProvider()
          .postWithdraw(
              MMService().client,
              GetWithdraw(
                userpass: MMService().userpass,
                fee: fee,
                coin: widget.coinBalance.coin.abbr,
                to: widget.addressToSend,
                amount: widget.amountToPay,
                max: double.parse(widget.coinBalance.balance.getBalance()) ==
                    double.parse(widget.amountToPay),
              ))
          .then((dynamic res) {
        withdrawResponse = res;
      }).catchError((dynamic onError) {
        widget.onError();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: _getFee(),
        builder: (BuildContext context, AsyncSnapshot<Object> snapshot) {
          final String gasCoin = GetFee.gasCoin(widget.coinBalance.coin.abbr);
          final bool needGas = gasCoin != null;
          bool notEnoughGas = false;
          bool isGasActive = false;

          Decimal fee = deci(0);
          Decimal gasFee = deci(0);
          if (snapshot.hasData && coinsDetailBloc.customFee == null) {
            try {
              fee = deci(snapshot.data);
            } catch (e) {
              Log.println('build_confirmation_step:78', e);
            }
          }

          if (coinsDetailBloc.customFee != null) {
            if (widget.coinBalance.coin.type == 'erc') {
              fee = deci(coinsDetailBloc.customFee.gas) *
                  deci(coinsDetailBloc.customFee.gasPrice) /
                  deci(1000000000); // eth gwei
            } else {
              fee = deci(coinsDetailBloc.customFee.amount);
            }
          }

          Decimal amountToPay = deci(widget.amountToPay);
          if (!needGas) amountToPay += fee;
          Decimal amountUserReceive = deci(widget.amountToPay);
          final Decimal userBalance = widget.coinBalance.balance.balance;

          if (amountToPay > userBalance) amountUserReceive = userBalance;

          if (userBalance == amountUserReceive) {
            amountToPay = amountUserReceive;
            if (!needGas || widget.coinBalance.coin.abbr == 'ETH') {
              amountUserReceive -= fee;
            }
          }

          CoinBalance gasBalance;
          for (CoinBalance coinBalance in coinsBloc.coinBalance) {
            if (coinBalance.coin.abbr == gasCoin) {
              gasBalance = coinBalance;
            }
          }

          isGasActive = gasBalance != null;
          gasFee = fee;

          if (isGasActive) {
            if (gasFee > gasBalance.balance.balance) notEnoughGas = true;

            if (widget.coinBalance.coin.abbr == 'ETH' &&
                amountUserReceive > gasBalance.balance.balance)
              notEnoughGas = true;
          }

          bool isButtonActive;
          if (needGas) {
            isButtonActive =
                isGasActive && (!notEnoughGas) && amountToPay > deci(0);
          } else {
            isButtonActive = amountToPay > deci(0);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).youAreSending,
                  style: Theme.of(context).textTheme.subtitle2,
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
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      widget.coinBalance.coin.abbr,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
                snapshot.connectionState == ConnectionState.waiting
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                            padding: const EdgeInsets.all(3),
                            height: 18,
                            width: 18,
                            child: const CircularProgressIndicator(
                              strokeWidth: 1.5,
                            )))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '- ',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(
                            !needGas
                                ? fee.toStringAsFixed(8)
                                : gasFee.toString(),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            needGas
                                ? AppLocalizations.of(context).gasFee(gasCoin)
                                : AppLocalizations.of(context).networkFee,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                needGas && isGasActive && notEnoughGas
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).notEnoughGas(gasCoin),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Theme.of(context).errorColor),
                          ),
                        ],
                      )
                    : Container(),
                needGas && !isGasActive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).gasNotActive(gasCoin),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
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
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        widget.coinBalance.coin.abbr,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  AppLocalizations.of(context).toAddress,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                const SizedBox(
                  height: 24,
                ),
                Container(
                  child: AutoSizeText(
                    widget.addressToSend,
                    style: Theme.of(context).textTheme.bodyText2,
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
                          key: const Key('primary-button-confirm'),
                          text: AppLocalizations.of(context)
                              .confirm
                              .toUpperCase(),
                          onPressed: isButtonActive && snapshot.hasData
                              ? () {
                                  _onPressedConfirmWithdraw(
                                      amountUserReceive.toDouble());
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
    } else if (withdrawResponse is WithdrawResponse) {
      widget.onConfirmPressed(withdrawResponse);
    } else {
      widget.onError();
    }
  }

  Future<double> _getFee() async {
    try {
      final dynamic tradeFeeResponse = await MM.getTradeFee(
          MMService().client, GetTradeFee(coin: widget.coinBalance.coin.abbr));
      if (tradeFeeResponse is TradeFee) {
        return double.parse(tradeFeeResponse.result.amount);
      } else {
        return 0;
      }
    } catch (e) {
      Log.println('build_confirmation_step:57', e);
      return 0;
    }
  }
}
