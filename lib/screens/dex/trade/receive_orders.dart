import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';

class ReceiveOrders extends StatefulWidget {
  const ReceiveOrders(
      {Key key,
      this.orderbooks,
      this.sellAmount,
      this.onCreateNoOrder,
      this.onCreateOrder})
      : super(key: key);

  final List<Orderbook> orderbooks;
  final Decimal sellAmount;
  final Function(String) onCreateNoOrder;
  final Function(Ask) onCreateOrder;

  @override
  _ReceiveOrdersState createState() => _ReceiveOrdersState();
}

class _ReceiveOrdersState extends State<ReceiveOrders> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).receiveLower),
      key: const Key('receive-list-coins'),
      children: widget.orderbooks
          .map((Orderbook orderbook) => OrderbookItem(
              key: Key('orderbook-item-${orderbook.base.toLowerCase()}'),
              orderbook: orderbook,
              onCreateNoOrder: widget.onCreateNoOrder,
              onCreateOrder: widget.onCreateOrder,
              sellAmount: widget.sellAmount))
          .toList(),
    );
  }
}

class OrderbookItem extends StatelessWidget {
  const OrderbookItem(
      {Key key,
      this.orderbook,
      this.sellAmount,
      this.onCreateNoOrder,
      this.onCreateOrder})
      : super(key: key);

  final Orderbook orderbook;
  final Decimal sellAmount;
  final Function(String) onCreateNoOrder;
  final Function(Ask) onCreateOrder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (orderbook.asks.isEmpty) {
          onCreateNoOrder(orderbook.base);
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement<dynamic, dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => AsksOrder(
                    asks: orderbook.asks,
                    baseCoin: orderbook.base,
                    sellAmount: sellAmount,
                    onCreateNoOrder: onCreateNoOrder,
                    onCreateOrder: onCreateOrder)),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 30,
              width: 30,
              child: Image.asset(
                'assets/${orderbook.base.toLowerCase()}.png',
              ),
            ),
            Flexible(
              child: orderbook.asks != null && orderbook.asks.isNotEmpty
                  ? RichText(
                      text: TextSpan(
                          style: Theme.of(context).textTheme.body1,
                          children: <InlineSpan>[
                            TextSpan(
                                text: AppLocalizations.of(context).clickToSee,
                                style: Theme.of(context).textTheme.body1),
                            TextSpan(
                                text: orderbook.asks.length.toString() + ' ',
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: AppLocalizations.of(context).orders,
                                style: Theme.of(context).textTheme.body1)
                          ]),
                    )
                  : Text(
                      AppLocalizations.of(context).noOrderAvailable,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class AsksOrder extends StatefulWidget {
  const AsksOrder(
      {Key key,
      this.asks,
      this.sellAmount,
      this.onCreateOrder,
      this.onCreateNoOrder,
      this.baseCoin})
      : super(key: key);
  final List<Ask> asks;
  final Decimal sellAmount;
  final Function(Ask) onCreateOrder;
  final Function(String) onCreateNoOrder;
  final String baseCoin;

  @override
  _AsksOrderState createState() => _AsksOrderState();
}

class _AsksOrderState extends State<AsksOrder> {
  @override
  Widget build(BuildContext context) {
    final List<DataRow> asksWidget = <DataRow>[];
    widget.asks.sort((Ask a, Ask b) => a.price.compareTo(b.price));
    widget.asks
        .asMap()
        .forEach((int index, Ask ask) => asksWidget.add(tableRow(ask, index)));

    return LockScreen(
      context: context,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(AppLocalizations.of(context).receiveLower),
              Container(
                  height: 30,
                  width: 30,
                  child: Image.asset(
                      'assets/${widget.baseCoin.toLowerCase()}.png')),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  DataTable(
                    columnSpacing: 4,
                    horizontalMargin: 12,
                    columns: <DataColumn>[
                      DataColumn(
                          label: Text(
                        AppLocalizations.of(context).price,
                        style: Theme.of(context).textTheme.subtitle,
                      )),
                      DataColumn(
                          label: Text(
                        AppLocalizations.of(context).availableVolume,
                        style: Theme.of(context).textTheme.subtitle,
                      )),
                      DataColumn(
                          label: Text(
                        AppLocalizations.of(context).receive.toLowerCase(),
                        style: Theme.of(context).textTheme.subtitle,
                      ))
                    ],
                    rows: asksWidget,
                  ),
                  CreateOrder(
                    onCreateNoOrder: widget.onCreateNoOrder,
                    baseCoin: widget.baseCoin,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow tableRow(Ask ask, int index) {
    return DataRow(selected: index % 2 == 1, cells: <DataCell>[
      DataCell(
          Container(
            key: Key('ask-item-$index'),
            child: Text(
              ask.getReceivePrice() + ' ' + ask.coin.toUpperCase(),
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12),
            ),
          ),
          onTap: () => createOrder(ask)),
      DataCell(
          Container(
            child: Text(
              ask.maxvolume.toStringAsFixed(8) + ' ' + ask.coin.toUpperCase(),
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12),
            ),
          ),
          onTap: () => createOrder(ask)),
      DataCell(
          Container(
            child: Text(
              ask.getReceiveAmount(widget.sellAmount) +
                  ' ' +
                  ask.coin.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          onTap: () => createOrder(ask))
    ]);
  }

  void createOrder(Ask ask) {
    Navigator.of(context).pop();
    widget.onCreateOrder(ask);
  }
}

class AskItem extends StatelessWidget {
  const AskItem({Key key, this.ask, this.sellAmount, this.onCreateOrder})
      : super(key: key);
  final Ask ask;
  final Decimal sellAmount;
  final Function(Ask) onCreateOrder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onCreateOrder(ask);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Container(
                color: Colors.red,
                child: Text(
                  ask.getReceivePrice() + ' ' + ask.coin.toUpperCase(),
                  style:
                      Theme.of(context).textTheme.body1.copyWith(fontSize: 12),
                ),
              ),
            ),
            Flexible(
                child: Container(
              color: Colors.red,
              child: Text(
                ask.maxvolume.toStringAsFixed(8) + ' ' + ask.coin.toUpperCase(),
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12),
              ),
            )),
            Flexible(
              child: Container(
                color: Colors.red,
                child: Text(
                  ask.getReceiveAmount(sellAmount) +
                      ' ' +
                      ask.coin.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CreateOrder extends StatelessWidget {
  const CreateOrder({this.onCreateNoOrder, this.baseCoin});
  final Function(String) onCreateNoOrder;
  final String baseCoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: () {
          onCreateNoOrder(baseCoin);
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_circle,
                size: 30,
                color: Theme.of(context).accentColor,
              ),
              const SizedBox(
                width: 16,
              ),
              Text(
                AppLocalizations.of(context).noOrderAvailable,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Theme.of(context).accentColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
