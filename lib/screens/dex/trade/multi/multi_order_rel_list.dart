import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/screens/dex/trade/multi/multi_order_rel_item.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class MultiOrderRelList extends StatefulWidget {
  @override
  _MultiOrderRelListState createState() => _MultiOrderRelListState();
}

class _MultiOrderRelListState extends State<MultiOrderRelList> {
  MultiOrderProvider multiOrderProvider;
  CexProvider cexProvider;
  final Map<String, TextEditingController> amtCtrls = {};
  final Map<String, FocusNode> amtFocusNodes = {};
  final TextEditingController fiatAmtCtrl = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAmtFields();
    });
    super.initState();
  }

  @override
  void dispose() {
    amtCtrls.forEach((_, ctrl) => ctrl.dispose());
    fiatAmtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);
    cexProvider ??= Provider.of<CexProvider>(context);

    return Card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeader(),
        StreamBuilder<List<CoinBalance>>(
            initialData: coinsBloc.coinBalance,
            stream: coinsBloc.outCoins,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final List<CoinBalance> availableToBuy =
                  coinsBloc.sortCoins(snapshot.data);

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 14, 0, 0),
                        child: Text(
                          AppLocalizations.of(context).multiTablePrice,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 14, 12, 0),
                          child: Text(
                            AppLocalizations.of(context).multiTableAmt,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      _buildToggleAll(),
                    ],
                  ),
                  ..._buildRows(availableToBuy),
                ],
              );
            }),
      ],
    ));
  }

  Widget _buildToggleAll() {
    return StreamBuilder<List<CoinBalance>>(
        initialData: coinsBloc.coinBalance,
        stream: coinsBloc.outCoins,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();

          bool allSelected = true;
          for (CoinBalance item in snapshot.data) {
            if (item.coin.abbr == multiOrderProvider.baseCoin) continue;

            if (!multiOrderProvider.isRelCoinSelected(item.coin.abbr)) {
              allSelected = false;
              break;
            }
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                final bool val = !allSelected;
                for (CoinBalance item in snapshot.data) {
                  if (!val) {
                    amtCtrls[item.coin.abbr]?.text = '';
                    multiOrderProvider.selectRelCoin(item.coin.abbr, false);
                  } else {
                    multiOrderProvider.selectRelCoin(item.coin.abbr, true);
                  }
                }
                _updateAmtFields();
                _calculateAmts();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: allSelected
                            ? Theme.of(context).accentColor
                            : Theme.of(context).textTheme.bodyText1.color,
                      )),
                  child: Icon(
                    Icons.done_all,
                    size: 11,
                    color: allSelected
                        ? Theme.of(context).accentColor
                        : Theme.of(context).textTheme.bodyText1.color,
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              AppLocalizations.of(context).multiReceiveTitle,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          InkWell(
            onTap: () {
              _showAutoFillDialog();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
              child: Icon(
                Icons.flash_auto,
                size: 14,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAutoFillDialog() {
    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(20),
            children: <Widget>[
              Text(AppLocalizations.of(context).multiFiatDesc),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('${cexProvider.selectedFiatSymbol} '),
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: fiatAmtCtrl,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      maxLines: 1,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor),
                        ),
                      ),
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(16),
                        DecimalTextInputFormatter(decimalRange: 8),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      fiatAmtCtrl.text = '';
                      dialogBloc.closeDialog(context);
                    },
                    child: Text(AppLocalizations.of(context).multiFiatCancel),
                  ),
                  const SizedBox(width: 12),
                  RaisedButton(
                    onPressed: () {
                      double fiatAmt;
                      try {
                        fiatAmt = double.parse(fiatAmtCtrl.text);
                      } catch (_) {}
                      fiatAmtCtrl.text = '';
                      dialogBloc.closeDialog(context);

                      if (fiatAmt == null || fiatAmt == 0) return;

                      final double usdAmt = fiatAmt *
                          cexProvider.getUsdPrice(cexProvider.selectedFiat);
                      _autofill(usdAmt);
                    },
                    child: Text(AppLocalizations.of(context).multiFiatFill),
                  ),
                ],
              ),
            ],
          );
        }).then((dynamic _) => dialogBloc.dialog = null);

    final double baseFiatAmt = _getBaseFiatAmt();
    if (baseFiatAmt != null) {
      fiatAmtCtrl.text = cutTrailingZeros(formatPrice(baseFiatAmt, 2));
    }
  }

  double _getBaseFiatAmt() {
    if (multiOrderProvider.baseAmt == null) return null;

    final double baseUsdPrice =
        cexProvider.getUsdPrice(multiOrderProvider.baseCoin);
    if (baseUsdPrice == null || baseUsdPrice == 0) return null;

    return multiOrderProvider.baseAmt *
        baseUsdPrice /
        cexProvider.getUsdPrice(cexProvider.selectedFiat);
  }

  List<Widget> _buildRows(List<CoinBalance> data) {
    final List<Widget> list = [];

    int count = 0;
    for (CoinBalance item in data) {
      if (item.coin.abbr == multiOrderProvider.baseCoin) continue;
      final Color color = count % 2 == 0
          ? Theme.of(context).highlightColor.withAlpha(15)
          : null;

      amtCtrls[item.coin.abbr] ??= TextEditingController();
      amtFocusNodes[item.coin.abbr] ??= FocusNode();

      list.add(
        MultiOrderRelItem(
            item: item,
            color: color,
            controller: amtCtrls[item.coin.abbr],
            focusNode: amtFocusNodes[item.coin.abbr],
            onSelectChange: (bool val) {
              multiOrderProvider.selectRelCoin(item.coin.abbr, val);
              if (val) {
                _updateAmtFields();
                _calculateAmts();
                if (multiOrderProvider.relCoins[item.coin.abbr].amount ==
                    null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                      FocusScope.of(context)
                          .requestFocus(amtFocusNodes[item.coin.abbr]));
                }
              } else {
                amtCtrls[item.coin.abbr].text = '';
              }
            }),
      );

      count++;
    }

    return list;
  }

  void _autofill(double sourceUsdAmt) {
    for (CoinBalance item in coinsBloc.coinBalance) {
      if (multiOrderProvider.baseCoin == item.coin.abbr) continue;
      final double usdPrice = cexProvider.getUsdPrice(item.coin.abbr);
      multiOrderProvider.selectRelCoin(item.coin.abbr, false);
      if (usdPrice == null || usdPrice == 0) continue;

      multiOrderProvider.selectRelCoin(item.coin.abbr, true);
    }

    _calculateAmts(sourceUsdAmt);
  }

  void _calculateAmts([double sourceUsdAmt]) {
    if (sourceUsdAmt == null)
      for (String abbr in multiOrderProvider.relCoins.keys) {
        final double relAmt = multiOrderProvider.relCoins[abbr]?.amount;
        if (relAmt == null || relAmt == 0) continue;

        final double sourceUsdPrice = cexProvider.getUsdPrice(abbr);
        if (sourceUsdPrice == null || sourceUsdPrice == 0) continue;

        sourceUsdAmt = relAmt * sourceUsdPrice;
        break;
      }

    sourceUsdAmt ??= (multiOrderProvider.baseAmt ?? 0) *
        cexProvider.getUsdPrice(multiOrderProvider.baseCoin);

    if (sourceUsdAmt == null || sourceUsdAmt == 0) return;

    multiOrderProvider.relCoins.forEach((abbr, MultiOrderRelCoin coin) {
      if (coin.amount != null) return;

      final double targetUsdPrice = cexProvider.getUsdPrice(abbr);
      if (targetUsdPrice == null || targetUsdPrice == 0) return;

      multiOrderProvider.setRelCoinAmt(
          abbr, double.parse(formatPrice(sourceUsdAmt / targetUsdPrice)));
    });

    _updateAmtFields();
  }

  void _updateAmtFields() {
    multiOrderProvider.relCoins.forEach((abbr, coin) {
      if (coin?.amount == null || coin?.amount == 0) {
        amtCtrls[abbr]?.text = '';
      } else {
        amtCtrls[abbr]?.text = cutTrailingZeros(formatPrice(coin.amount));
      }
    });
  }
}
