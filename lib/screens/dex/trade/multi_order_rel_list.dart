import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
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

    return Container(
      width: double.infinity,
      child: Card(
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

                return Table(
                  columnWidths: const {
                    0: MinColumnWidth(
                      FractionColumnWidth(0.4),
                      IntrinsicColumnWidth(flex: 1),
                    ),
                    1: MinColumnWidth(
                      FractionColumnWidth(0.4),
                      IntrinsicColumnWidth(),
                    ),
                    2: IntrinsicColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                          border: Border(
                        top: BorderSide(
                          width: 1,
                          color: Theme.of(context).highlightColor,
                        ),
                      )),
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 14, 0, 0),
                          child: Text(
                            // TODO(yurii): localization
                            'Price/CEX',
                            style: Theme.of(context).textTheme.body2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 14, 12, 0),
                          child: Text(
                            // TODO(yurii): localization
                            'Receive Amt.',
                            style: Theme.of(context).textTheme.body2,
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
      )),
    );
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
                            : Theme.of(context).textTheme.body2.color,
                      )),
                  child: Icon(
                    Icons.done_all,
                    size: 11,
                    color: allSelected
                        ? Theme.of(context).accentColor
                        : Theme.of(context).textTheme.body2.color,
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
              // TODO(yurii): localization
              'Receive:',
              style: Theme.of(context).textTheme.body2,
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
                color: Theme.of(context).textTheme.body2.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAutoFillDialog() {
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(20),
            children: <Widget>[
              // TODO(yurii): localization
              const Text('Please enter fiat amount to receive:'),
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
                    // TODO(yurii): localization
                    child: const Text('Cancel'),
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
                    // TODO(yurii): localization
                    child: const Text('Autofill'),
                  ),
                ],
              ),
            ],
          );
        });

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

  List<TableRow> _buildRows(List<CoinBalance> data) {
    final List<TableRow> list = [];

    int count = 0;
    for (CoinBalance item in data) {
      if (item.coin.abbr == multiOrderProvider.baseCoin) continue;
      final Color color = count % 2 == 0
          ? Theme.of(context).highlightColor.withAlpha(15)
          : null;

      list.add(
        TableRow(
          decoration: BoxDecoration(
            color: color,
          ),
          children: [
            _buildTitle(item),
            _buildAmount(item),
            _buildSwitch(item),
          ],
        ),
      );

      final String error = multiOrderProvider.getError(item.coin.abbr);
      if (error != null) {
        list.add(TableRow(
          decoration: BoxDecoration(
            color: color,
          ),
          children: [
            Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Container(
                  height: 16,
                ),
                Positioned(
                  width: MediaQuery.of(context).size.width - 8 - 10 - 16,
                  height: 16,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Text(
                      '$error',
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Theme.of(context).errorColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(),
            const SizedBox(),
          ],
        ));
      }

      // spacer
      list.add(TableRow(
          decoration: BoxDecoration(
            color: color,
          ),
          children: const [
            SizedBox(height: 4),
            SizedBox(),
            SizedBox(),
          ]));

      count++;
    }

    return list;
  }

  Widget _buildSwitch(CoinBalance item) {
    return Switch(
        value: multiOrderProvider.isRelCoinSelected(item.coin.abbr),
        onChanged: (bool val) {
          multiOrderProvider.selectRelCoin(item.coin.abbr, val);
          if (val) {
            _updateAmtFields();
            _calculateAmts();
            if (multiOrderProvider.relCoins[item.coin.abbr] == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  FocusScope.of(context)
                      .requestFocus(amtFocusNodes[item.coin.abbr]));
            }
          } else {
            amtCtrls[item.coin.abbr].text = '';
          }
        });
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
        final double relAmt = multiOrderProvider.relCoins[abbr];
        if (relAmt == null || relAmt == 0) continue;

        final double sourceUsdPrice = cexProvider.getUsdPrice(abbr);
        if (sourceUsdPrice == null || sourceUsdPrice == 0) continue;

        sourceUsdAmt = relAmt * sourceUsdPrice;
        break;
      }

    sourceUsdAmt ??= (multiOrderProvider.baseAmt ?? 0) *
        cexProvider.getUsdPrice(multiOrderProvider.baseCoin);

    if (sourceUsdAmt == null || sourceUsdAmt == 0) return;

    multiOrderProvider.relCoins.forEach((abbr, amt) {
      if (amt != null) return;

      final double targetUsdPrice = cexProvider.getUsdPrice(abbr);
      if (targetUsdPrice == null || targetUsdPrice == 0) return;

      multiOrderProvider.setRelCoinAmt(
          abbr, double.parse(formatPrice(sourceUsdAmt / targetUsdPrice)));
    });

    _updateAmtFields();
  }

  Widget _buildAmount(CoinBalance item) {
    amtCtrls[item.coin.abbr] ??= TextEditingController();
    amtFocusNodes[item.coin.abbr] ??= FocusNode();

    if (!multiOrderProvider.isRelCoinSelected(item.coin.abbr))
      return Container();

    final double usdPrice = cexProvider.getUsdPrice(item.coin.abbr) ?? 0;
    final double usdAmt =
        (multiOrderProvider.getRelCoinAmt(item.coin.abbr) ?? 0) * usdPrice;
    final String convertedAmt = usdAmt > 0 ? cexProvider.convert(usdAmt) : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 32,
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: amtCtrls[item.coin.abbr],
              focusNode: amtFocusNodes[item.coin.abbr],
              textAlign: TextAlign.right,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 4),
              ),
              maxLines: 1,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(16),
                DecimalTextInputFormatter(decimalRange: 8),
              ],
              onChanged: (String value) {
                double amnt;
                try {
                  amnt = double.parse(value);
                } catch (_) {}

                multiOrderProvider.setRelCoinAmt(
                    item.coin.abbr, value == '' ? null : amnt);
              },
            ),
          ),
          if (convertedAmt != null)
            Text(
              convertedAmt,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: cexColor,
                fontSize: 10,
                height: 1.2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle(CoinBalance item) {
    return Opacity(
      opacity: multiOrderProvider.isRelCoinSelected(item.coin.abbr) ? 1 : 0.5,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    maxRadius: 6,
                    backgroundImage: AssetImage(
                        'assets/${item.coin.abbr.toLowerCase()}.png'),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.coin.abbr,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                  padding: const EdgeInsets.only(left: 2),
                  child: _buildPrice(item)),
              _buildFee(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFee(CoinBalance item) {
    if (!multiOrderProvider.isRelCoinSelected(item.coin.abbr))
      return Container();
    if (item.coin.swapContractAddress.isEmpty) return Container();

    return FutureBuilder(
        future: multiOrderProvider.getERCfee(item.coin.abbr),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          return Container(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              // TODO(yurii): localization
              '+fee: ${cutTrailingZeros(formatPrice(snapshot.data))}'
              ' ETH',
              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 10),
            ),
          );
        });
  }

  Widget _buildPrice(CoinBalance item) {
    final double sellAmt = multiOrderProvider.baseAmt;
    final double relAmt = multiOrderProvider.getRelCoinAmt(item.coin.abbr);
    if (relAmt == null || relAmt == 0) return Container();
    if (sellAmt == null || sellAmt == 0) return Container();

    final double price = relAmt / sellAmt;
    final double cexPrice = cexProvider.getCexRate(CoinsPair(
        buy: item.coin,
        sell: coinsBloc.getCoinByAbbr(multiOrderProvider.baseCoin)));
    double delta;
    if (cexPrice != null && cexPrice != 0) {
      delta = (cexPrice - price) * 100 / cexPrice;
      if (delta > 100) delta = 100;
      if (delta < -100) delta = -100;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          formatPrice(price),
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).disabledColor,
          ),
        ),
        _buildDelta(delta),
      ],
    );
  }

  Widget _buildDelta(double delta) {
    if (delta == null) return Container();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: delta.abs() < 0.01
          ? <Widget>[
              const SizedBox(width: 3),
              const Text(
                '≈0.00%',
                style: TextStyle(
                  fontSize: 10,
                  color: cexColor,
                ),
              ),
            ]
          : <Widget>[
              const SizedBox(width: 3),
              Text(
                delta > 0 ? '+' : '',
                style: TextStyle(
                  fontSize: 10,
                  color: delta > 0 ? Colors.orange : Colors.green,
                ),
              ),
              Text(
                '${formatPrice(delta, 2)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: delta > 0 ? Colors.orange : Colors.green,
                ),
              ),
            ],
    );
  }

  void _updateAmtFields() {
    multiOrderProvider.relCoins.forEach((abbr, amount) {
      if (amount == null || amount == 0) {
        amtCtrls[abbr]?.text = '';
      } else {
        amtCtrls[abbr]?.text = cutTrailingZeros(formatPrice(amount));
      }
    });
  }
}
