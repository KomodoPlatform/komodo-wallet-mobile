import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);
    cexProvider ??= Provider.of<CexProvider>(context);

    return Container(
      width: double.infinity,
      child: Card(
          child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 4, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                            child: Text(
                              'Price/CEX',
                              style: Theme.of(context).textTheme.body2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                            child: Text(
                              'Receive Amt.',
                              style: Theme.of(context).textTheme.body2,
                            ),
                          ),
                          Container(),
                        ],
                      ),
                      ..._buildRows(availableToBuy),
                    ],
                  );
                }),
          ],
        ),
      )),
    );
  }

  List<TableRow> _buildRows(List<CoinBalance> data) {
    final List<TableRow> list = [];

    for (CoinBalance item in data) {
      if (item.coin.abbr == multiOrderProvider.baseCoin) continue;

      list.add(
        TableRow(children: [
          _buildTitle(item),
          _buildAmount(item),
          _buildSwitch(item),
        ]),
      );
    }

    return list;
  }

  Widget _buildSwitch(CoinBalance item) {
    return SizedBox(
        height: 46,
        child: Switch(
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
            }));
  }

  void _calculateAmts() {
    final double baseAmt = multiOrderProvider.baseAmt;
    if (baseAmt == null || baseAmt == 0) return;

    double sourceDelta;

    for (String abbr in multiOrderProvider.relCoins.keys) {
      final double relAmt = multiOrderProvider.relCoins[abbr];
      if (relAmt == null || relAmt == 0) continue;

      final double price = relAmt / baseAmt;
      final double cexPrice = cexProvider.getCexRate(CoinsPair(
        buy: Coin(abbr: abbr),
        sell: Coin(abbr: multiOrderProvider.baseCoin),
      ));

      if (cexPrice == null || cexPrice == 0) continue;

      sourceDelta = (cexPrice - price) * 100 / cexPrice;
      break;
    }

    if (sourceDelta == null) return;

    multiOrderProvider.relCoins.forEach((abbr, amt) {
      if (amt != null) return;

      final double cexPrice = cexProvider.getCexRate(CoinsPair(
        buy: Coin(abbr: abbr),
        sell: Coin(abbr: multiOrderProvider.baseCoin),
      ));
      if (cexPrice == null || cexPrice == 0) return;

      final double price = cexPrice - (sourceDelta * cexPrice) / 100;
      multiOrderProvider.setRelCoinAmt(
          abbr, double.parse(formatPrice(baseAmt * price)));
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
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 36,
            child: TextField(
              controller: amtCtrls[item.coin.abbr],
              focusNode: amtFocusNodes[item.coin.abbr],
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              maxLines: 1,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 8),
              ),
              onChanged: (String value) {
                multiOrderProvider.setRelCoinAmt(
                    item.coin.abbr, value == '' ? null : double.parse(value));
              },
            ),
          ),
          if (convertedAmt != null)
            Text(
              convertedAmt,
              textAlign: TextAlign.right,
              style: TextStyle(
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
          padding: const EdgeInsets.fromLTRB(0, 6, 12, 6),
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
    if (item.coin.swapContractAddress.isEmpty) return const SizedBox();

    return FutureBuilder(
        future: multiOrderProvider.getERCfee(item.coin.abbr),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          return Container(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
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
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        Text(
          formatPrice(price),
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).disabledColor,
          ),
        ),
        if (delta != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
          ),
      ],
    );
  }

  void _updateAmtFields() {
    multiOrderProvider.relCoins.forEach((abbr, amount) {
      if (amount == null || amount == 0) {
        amtCtrls[abbr].text = '';
      } else {
        amtCtrls[abbr].text = cutTrailingZeros(formatPrice(amount));
      }
    });
  }
}
