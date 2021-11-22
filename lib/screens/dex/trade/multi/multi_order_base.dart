import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:provider/provider.dart';

class MultiOrderBase extends StatefulWidget {
  @override
  _MultiOrderBaseState createState() => _MultiOrderBaseState();
}

class _MultiOrderBaseState extends State<MultiOrderBase> {
  MultiOrderProvider multiOrderProvider;
  CexProvider cexProvider;
  String baseCoin;
  List<CoinBalance> coins = coinsBloc.coinBalance;
  TextEditingController amountCtrl = TextEditingController();
  bool isDialogOpen = false;

  @override
  void initState() {
    coinsBloc.outCoins.listen((data) {
      if (coins == data) return;

      setState(() {
        coins = data;
      });
      if (isDialogOpen) {
        dialogBloc.closeDialog(context);
        _showCoinSelectDialog();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (multiOrderProvider.baseAmt != null) {
        amountCtrl.text =
            cutTrailingZeros(formatPrice(multiOrderProvider.baseAmt, 8));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    amountCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);
    cexProvider ??= Provider.of<CexProvider>(context);
    baseCoin = multiOrderProvider.baseCoin;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Table(
              columnWidths: const {
                1: FixedColumnWidth(16),
              },
              children: [
                TableRow(
                  children: [
                    Text(
                      AppLocalizations.of(context).multiSellTitle,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildResetButton(),
                    )
                  ],
                ),
                TableRow(
                  children: [
                    _buildCoinSelect(),
                    SizedBox(),
                    _buildSellAmount(),
                  ],
                )
              ],
            ),
            ..._buildErrors(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildErrors() {
    final String error =
        baseCoin == null ? null : multiOrderProvider.getError(baseCoin);
    if (error == null) return [SizedBox()];

    return [
      const SizedBox(height: 16),
      Text(
        error,
        style: Theme.of(context).textTheme.caption.copyWith(
              color: Theme.of(context).errorColor,
            ),
      ),
    ];
  }

  Widget _buildResetButton() {
    return IconButton(
      onPressed: multiOrderProvider.baseCoin == null
          ? null
          : () {
              multiOrderProvider.reset();
              amountCtrl.text = '';
            },
      constraints: BoxConstraints(maxHeight: 16, maxWidth: 16),
      padding: EdgeInsets.all(0),
      iconSize: 16,
      splashRadius: 16,
      visualDensity: VisualDensity.compact,
      icon: Opacity(
        opacity: multiOrderProvider.baseCoin == null ? 0.3 : 1,
        child: Icon(Icons.clear),
      ),
    );
  }

  Widget _buildCoinSelect() {
    return InkWell(
      onTap: () => _showCoinSelectDialog(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Theme.of(context).focusColor,
        ))),
        child: Opacity(
          opacity: baseCoin == null ? 0.3 : 1,
          child: Row(
            children: <Widget>[
              CircleAvatar(
                maxRadius: 12,
                backgroundColor: baseCoin == null
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                backgroundImage: baseCoin == null
                    ? null
                    : AssetImage(
                        'assets/coin-icons/${baseCoin.toLowerCase()}.png'),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  baseCoin ?? AppLocalizations.of(context).multiBasePlaceholder,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoinSelectDialog() {
    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (context) {
          if (coins == null)
            return CustomSimpleDialog(
              children: const [
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            );

          final List<CoinBalance> availableForSell =
              coins.where((CoinBalance coin) {
            return !coin.coin.walletOnly && coin.balance.balance.toDouble() > 0;
          }).toList();

          if (availableForSell.isEmpty) {
            return _buildNoFundsAlert();
          }

          return CustomSimpleDialog(
            hasHorizontalPadding: false,
            title: Text(AppLocalizations.of(context).multiBaseSelectTitle),
            children: coinsBloc
                .sortCoins(availableForSell)
                .map<Widget>((CoinBalance item) {
              return InkWell(
                onTap: () {
                  multiOrderProvider.baseCoin = item.coin.abbr;
                  amountCtrl.text = '';
                  dialogBloc.closeDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        maxRadius: 12,
                        backgroundImage: AssetImage(
                            'assets/coin-icons/${item.coin.abbr.toLowerCase()}.png'),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.coin.abbr,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      Expanded(
                          child: Text(
                        cutTrailingZeros(
                            formatPrice(item.balance.balance.toDouble(), 8)),
                        textAlign: TextAlign.right,
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }).then((dynamic _) => dialogBloc.dialog = null);
  }

  Widget _buildNoFundsAlert() {
    return CustomSimpleDialog(
      title: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 48,
          ),
          const SizedBox(width: 12),
          Text(AppLocalizations.of(context).noFunds,
              style: Theme.of(context).textTheme.headline6),
        ],
      ),
      children: <Widget>[
        Text(AppLocalizations.of(context).noFundsDetected,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(
          height: 24,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            ElevatedButton(
              child: Text(AppLocalizations.of(context).goToPorfolio),
              onPressed: () {
                Navigator.of(context).pop();
                mainBloc.setCurrentIndexTab(0);
              },
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSellAmount() {
    final double usdPrice =
        cexProvider.getUsdPrice(multiOrderProvider?.baseCoin) ?? 0;
    final double usdAmt = (multiOrderProvider?.baseAmt ?? 0) * usdPrice;
    final String convertedAmt = usdAmt > 0 ? cexProvider.convert(usdAmt) : null;

    return Opacity(
      opacity: baseCoin == null ? 0.3 : 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 0, 0, 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 38,
                    padding: const EdgeInsets.only(top: 4),
                    child: TextFormField(
                      controller: amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: AppLocalizations.of(context)
                            .multiBaseAmtPlaceholder,
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (String value) {
                        double amnt;
                        try {
                          amnt = double.parse(value);
                        } catch (_) {}

                        multiOrderProvider.baseAmt =
                            value.isEmpty ? null : amnt;
                        multiOrderProvider.isMax = false;
                      },
                      enabled: multiOrderProvider.baseCoin != null,
                      maxLines: 1,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(16),
                        DecimalTextInputFormatter(decimalRange: 8),
                      ],
                    ),
                  ),
                  if (convertedAmt != null)
                    Container(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        convertedAmt,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.caption.copyWith(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? cexColorLight
                                  : cexColor,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            if (multiOrderProvider.baseCoin != null)
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: multiOrderProvider.baseCoin == null
                    ? null
                    : () async {
                        multiOrderProvider.isMax = true;
                        multiOrderProvider.baseAmt =
                            multiOrderProvider.getMaxSellAmt();
                        amountCtrl.text = cutTrailingZeros(
                                formatPrice(multiOrderProvider.baseAmt)) ??
                            '';
                      },
                child: Text('MAX'),
              ),
          ],
        ),
      ),
    );
  }
}
