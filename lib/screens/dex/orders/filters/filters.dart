import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_page.dart';

class Filters extends StatefulWidget {
  const Filters({this.items, this.activeFilters, this.onChange});

  final List<dynamic> items;
  final Function(ActiveFilters) onChange;
  final ActiveFilters activeFilters;

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  ActiveFilters _filters;

  @override
  Widget build(BuildContext context) {
    _filters ??= widget.activeFilters;

    return Container(
      child: Column(
        children: [
          _buildCoinFilter(Market.SELL),
          SizedBox(height: 12),
          _buildCoinFilter(Market.RECEIVE),
          SizedBox(height: 12),
          _buildTypeFilter(),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    final OrderType current = widget.activeFilters.type;
    final Color color =
        current == null ? Theme.of(context).textTheme.bodyText1.color : null;

    return Row(children: [
      Expanded(
        child: Text(
          'Type:',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      InkWell(
        onTap: () => _openTypeDialog(),
        child: Container(
          width: 100,
          padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(
              color: Theme.of(context).accentColor.withAlpha(150),
              width: 1,
            ),
          )),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  current == null
                      ? 'All'
                      : current == OrderType.MAKER
                          ? 'Maker'
                          : 'Taker',
                  style: TextStyle(color: color),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: color,
              )
            ],
          ),
        ),
      ),
      InkWell(
        child: Container(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Opacity(
            opacity: current == null ? 0.5 : 1,
            child: Icon(
              Icons.clear,
              size: 16,
            ),
          ),
        ),
        onTap: current == null
            ? null
            : () {
                setState(() {
                  _filters.type = null;
                });
                widget.onChange(_filters);
              },
      )
    ]);
  }

  void _openTypeDialog() {
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 4),
            children: [
              InkWell(
                child:
                    Container(padding: EdgeInsets.all(12), child: Text('All')),
              ),
              InkWell(
                child: Container(
                    padding: EdgeInsets.all(12), child: Text('Maker')),
              ),
              InkWell(
                child: Container(
                    padding: EdgeInsets.all(12), child: Text('Taker')),
              ),
            ],
          );
        });
  }

  Widget _buildCoinFilter(Market market) {
    final String current =
        market == Market.SELL ? _filters.sellCoin : _filters.receiveCoin;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            market == Market.SELL ? 'Sell coin:' : 'Receive coin:',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        _buildCoinSelect(market),
        InkWell(
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Opacity(
              opacity: current == null ? 0.5 : 1,
              child: Icon(
                Icons.clear,
                size: 16,
              ),
            ),
          ),
          onTap: current == null
              ? null
              : () {
                  setState(() {
                    market == Market.SELL
                        ? _filters.sellCoin = null
                        : _filters.receiveCoin = null;
                  });
                  widget.onChange(_filters);
                },
        )
      ],
    );
  }

  Widget _buildCoinSelect(Market market) {
    final String current =
        market == Market.SELL ? _filters.sellCoin : _filters.receiveCoin;
    final Color color =
        current == null ? Theme.of(context).textTheme.bodyText1.color : null;

    return InkWell(
      onTap: () => _openCoinsDialog(market),
      child: Container(
        width: 100,
        padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            color: Theme.of(context).accentColor.withAlpha(150),
            width: 1,
          ),
        )),
        child: Row(
          children: [
            CircleAvatar(
              radius: 7,
              backgroundColor: color?.withAlpha(50),
              backgroundImage: current != null
                  ? AssetImage('assets/${current.toLowerCase()}.png')
                  : null,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                current ?? 'All',
                style: TextStyle(color: color),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: color,
            )
          ],
        ),
      ),
    );
  }

  void _openCoinsDialog(Market market) {
    final List<String> coins = _getCoins(market);
    final List<Widget> items = coins.map((String coin) {
      return InkWell(
        onTap: () {
          setState(() {
            market == Market.SELL
                ? _filters.sellCoin = coin
                : _filters.receiveCoin = coin;
          });
          widget.onChange(_filters);
          dialogBloc.closeDialog(context);
        },
        child: Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 8,
                backgroundImage: AssetImage('assets/${coin.toLowerCase()}.png'),
              ),
              SizedBox(width: 4),
              Text(coin),
            ],
          ),
        ),
      );
    }).toList();

    items.insert(
        0,
        InkWell(
          onTap: () {
            setState(() {
              market == Market.SELL
                  ? _filters.sellCoin = null
                  : _filters.receiveCoin = null;
            });
            widget.onChange(_filters);
            dialogBloc.closeDialog(context);
          },
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                    radius: 8,
                    backgroundColor: Theme.of(context).highlightColor),
                SizedBox(width: 4),
                Text('All'),
              ],
            ),
          ),
        ));

    dialogBloc.dialog = showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 4),
            children: items,
          );
        });
  }

  List<String> _getCoins(Market market) {
    final List<String> list = [];

    for (dynamic item in widget.items) {
      if (item is Order) {
        String coin;
        switch (market) {
          case Market.SELL:
            coin = item.orderType == OrderType.MAKER ? item.base : item.rel;
            break;
          case Market.RECEIVE:
            coin = item.orderType == OrderType.MAKER ? item.rel : item.base;
            break;
        }
        if (!list.contains(coin)) list.add(coin);
      } else if (item is Swap) {
        String coin;
        switch (market) {
          case Market.SELL:
            coin = item.isMaker ? item.makerAbbr : item.takerAbbr;
            break;
          case Market.RECEIVE:
            coin = item.isMaker ? item.takerAbbr : item.makerAbbr;
            break;
        }
        if (!list.contains(coin)) list.add(coin);
      }
    }

    return list;
  }
}

class ActiveFilters {
  ActiveFilters({
    this.matches,
    this.sellCoin,
    this.receiveCoin,
    this.type,
  });

  int matches;
  String sellCoin;
  String receiveCoin;
  OrderType type;
}
