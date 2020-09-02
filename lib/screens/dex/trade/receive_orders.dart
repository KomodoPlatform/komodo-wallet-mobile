import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

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
  final double sellAmount;
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
  final double sellAmount;
  final Function(Ask) onCreateOrder;
  final Function(String) onCreateNoOrder;
  final String baseCoin;

  @override
  _AsksOrderState createState() => _AsksOrderState();
}

class _AsksOrderState extends State<AsksOrder> {
  OrderBookProvider orderBookProvider;
  CexProvider cexProvider;

  @override
  Widget build(BuildContext context) {
    cexProvider = Provider.of<CexProvider>(context);
    orderBookProvider = Provider.of<OrderBookProvider>(context);
    final List<TableRow> asksWidget = <TableRow>[];
    final Orderbook orderbook = orderBookProvider?.getOrderBook(CoinsPair(
      buy: coinsBloc.getCoinByAbbr(widget.baseCoin),
      sell: orderBookProvider.activePair.sell,
    ));
    List<Ask> asksList = orderbook?.asks;

    asksList = OrderBookProvider.sortByPrice(asksList);
    asksList
        ?.asMap()
        ?.forEach((int index, Ask ask) => asksWidget.add(tableRow(ask, index)));

    return LockScreen(
      context: context,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  AppLocalizations.of(context).receiveLower,
                  key: const Key('title-ask-orders'),
                ),
              ),
              _buildCexRate(),
              const SizedBox(width: 4),
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
              child: orderbook == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: <Widget>[
                        asksWidget.isEmpty
                            ? Container(
                                alignment: const Alignment(0, 0),
                                padding: const EdgeInsets.only(top: 30),
                                child: Text(
                                  'No matching orders found',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).highlightColor,
                                ))),
                                child: Table(
                                  children: [
                                    TableRow(children: [
                                      Container(
                                        height: 50,
                                        alignment: const Alignment(-1, 0),
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 6,
                                        ),
                                        child: Text(
                                          '${AppLocalizations.of(context).price}'
                                          ' (${widget.baseCoin})',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        alignment: const Alignment(1, 0),
                                        padding: const EdgeInsets.only(
                                          left: 6,
                                        ),
                                        child: Text(
                                          '${AppLocalizations.of(context).availableVolume}'
                                          ' (${widget.baseCoin})',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        alignment: const Alignment(1, 0),
                                        padding: const EdgeInsets.only(
                                          left: 6,
                                          right: 12,
                                        ),
                                        child: Text(
                                          '${AppLocalizations.of(context).receive.toLowerCase()}'
                                          ' (${widget.baseCoin})',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle
                                              .copyWith(fontSize: 14),
                                        ),
                                      ),
                                    ]),
                                    ...asksWidget,
                                  ],
                                ),
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

  Widget _buildCexRate() {
    final double cexRate = cexProvider.getCexRate(CoinsPair(
          sell: coinsBloc.getCoinByAbbr(widget.baseCoin),
          buy: orderBookProvider.activePair.sell,
        )) ??
        0.0;

    if (cexRate == 0.0) return Container();

    return Row(
      children: <Widget>[
        CexMarker(
          context,
          size: const Size.fromHeight(13),
        ),
        const SizedBox(width: 2),
        Text(
          formatPrice(cexRate),
          style: TextStyle(
              fontSize: 14, color: cexColor, fontWeight: FontWeight.w400),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  TableRow tableRow(Ask ask, int index) {
    return TableRow(
      children: [
        TableRowInkWell(
            child: Container(
              height: 40,
              alignment: const Alignment(-1, 0),
              padding: const EdgeInsets.only(
                left: 12,
                right: 6,
              ),
              decoration: BoxDecoration(
                  color: index % 2 > 0
                      ? null
                      : Theme.of(context).primaryColor.withAlpha(150),
                  border: Border(
                      top: BorderSide(
                    width: 1,
                    color: Theme.of(context).highlightColor,
                  ))),
              key: Key('ask-item-$index'),
              child: Text(
                formatPrice(ask.getReceivePrice().toDouble()),
                style: Theme.of(context).textTheme.body1.copyWith(
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
              ),
            ),
            onTap: () => createOrder(ask)),
        TableRowInkWell(
            child: Container(
              height: 40,
              alignment: const Alignment(1, 0),
              padding: const EdgeInsets.only(
                left: 6,
              ),
              decoration: BoxDecoration(
                  color: index % 2 > 0
                      ? null
                      : Theme.of(context).primaryColor.withAlpha(150),
                  border: Border(
                      top: BorderSide(
                    width: 1,
                    color: Theme.of(context).highlightColor,
                  ))),
              child: Text(
                formatPrice(ask.maxvolume.toDouble()),
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12),
              ),
            ),
            onTap: () => createOrder(ask)),
        TableRowInkWell(
            child: Container(
              height: 40,
              alignment: const Alignment(1, 0),
              padding: const EdgeInsets.only(
                left: 6,
                right: 12,
              ),
              decoration: BoxDecoration(
                  color: index % 2 > 0
                      ? null
                      : Theme.of(context).primaryColor.withAlpha(150),
                  border: Border(
                      top: BorderSide(
                    width: 1,
                    color: Theme.of(context).highlightColor,
                  ))),
              child: Text(
                formatPrice(
                    ask.getReceiveAmount(deci(widget.sellAmount)).toDouble()),
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 12),
              ),
            ),
            onTap: () => createOrder(ask))
      ],
    );
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
  final double sellAmount;
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
                  deci2s(ask.getReceivePrice()) + ' ' + ask.coin.toUpperCase(),
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
                  deci2s(ask.getReceiveAmount(deci(sellAmount))) +
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
