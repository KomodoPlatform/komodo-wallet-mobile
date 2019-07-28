import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/orderbook.dart';

class ReceiveOrders extends StatefulWidget {
  const ReceiveOrders(
      {Key key,
      this.orderbooks,
      this.sellAmount,
      this.onCreateNoOrder,
      this.onCreateOrder})
      : super(key: key);

  final List<Orderbook> orderbooks;
  final double sellAmount;
  final Function(String) onCreateNoOrder;
  final Function(String, String) onCreateOrder;

  @override
  _ReceiveOrdersState createState() => _ReceiveOrdersState();
}

class _ReceiveOrdersState extends State<ReceiveOrders> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).receiveLower),
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
  final double sellAmount;
  final Function(String) onCreateNoOrder;
  final Function(String, String) onCreateOrder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (orderbook.asks.isEmpty) {
          onCreateNoOrder(orderbook.base);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          dialogBloc.dialog = showDialog<List<Ask>>(
              context: context,
              builder: (BuildContext context) {
                return AsksOrder(
                    asks: orderbook.asks,
                    baseCoin: orderbook.base,
                    sellAmount: sellAmount,
                    onCreateNoOrder: onCreateNoOrder,
                    onCreateOrder: onCreateOrder);
              });
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
  final double sellAmount;
  final Function(String, String) onCreateOrder;
  final Function(String) onCreateNoOrder;
  final String baseCoin;

  @override
  _AsksOrderState createState() => _AsksOrderState();
}

class _AsksOrderState extends State<AsksOrder> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> asksWidget = <Widget>[];
    widget.asks.sort((Ask a, Ask b) => a.price.compareTo(b.price));
    widget.asks.asMap().forEach((int index, Ask ask) => asksWidget.add(AskItem(
          key: Key('ask-item-$index'),
          ask: ask,
          sellAmount: widget.sellAmount,
          onCreateOrder: widget.onCreateOrder,
        )));

    return SimpleDialog(
      title: Text(AppLocalizations.of(context).receiveLower),
      children: <Widget>[
        ...asksWidget,
        CreateOrder(
            onCreateNoOrder: widget.onCreateNoOrder, baseCoin: widget.baseCoin)
      ],
    );
  }
}

class AskItem extends StatelessWidget {
  const AskItem({Key key, this.ask, this.sellAmount, this.onCreateOrder})
      : super(key: key);
  final Ask ask;
  final double sellAmount;
  final Function(String, String) onCreateOrder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onCreateOrder(ask.coin, ask.getReceiveAmount(sellAmount));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                height: 30,
                width: 30,
                child: Image.asset('assets/${ask.coin.toLowerCase()}.png')),
            Text(
                ask.getReceiveAmount(sellAmount) + ' ' + ask.coin.toUpperCase())
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
          padding:
              const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                Icons.add_circle,
                size: 30,
                color: Theme.of(context).accentColor,
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
