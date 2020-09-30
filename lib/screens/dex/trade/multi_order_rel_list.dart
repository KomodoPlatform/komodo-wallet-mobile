import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:provider/provider.dart';

class MultiOrderRelList extends StatefulWidget {
  @override
  _MultiOrderRelListState createState() => _MultiOrderRelListState();
}

class _MultiOrderRelListState extends State<MultiOrderRelList> {
  MultiOrderProvider multiOrderProvider;

  @override
  Widget build(BuildContext context) {
    multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);

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
                      0: IntrinsicColumnWidth(flex: 1),
                      1: FractionColumnWidth(0.4),
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
      if (item.coin.abbr == multiOrderProvider.baseCoin?.coin?.abbr) continue;

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
        height: 46, child: Switch(value: false, onChanged: (bool val) {}));
  }

  Widget _buildAmount(CoinBalance item) {
    return SizedBox(
      height: 34,
      child: Container(
        padding: const EdgeInsets.only(right: 12),
        child: TextField(
          textAlign: TextAlign.right,
          keyboardType: TextInputType.number,
          maxLines: 1,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 8),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(CoinBalance item) {
    return Container(
      height: 46,
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
                backgroundImage:
                    AssetImage('assets/${item.coin.abbr.toLowerCase()}.png'),
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
        ],
      ),
    );
  }

  Widget _buildPrice(CoinBalance item) {
    return Row(
      children: <Widget>[
        Text(
          '9.23453',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '+2.12%',
          style: TextStyle(
            fontSize: 10,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}
