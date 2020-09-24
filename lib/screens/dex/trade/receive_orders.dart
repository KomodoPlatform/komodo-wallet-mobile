import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/trade/receive_orders_chart.dart';
import 'package:komodo_dex/screens/markets/build_order_details.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class ReceiveOrders extends StatefulWidget {
  const ReceiveOrders({
    Key key,
    this.sellAmount,
    this.onCreateNoOrder,
    this.onCreateOrder,
    this.orderbooks,
  }) : super(key: key);

  final double sellAmount;
  final Function(String) onCreateNoOrder;
  final Function(Ask) onCreateOrder;
  final List<Orderbook> orderbooks; // for integration tests

  @override
  _ReceiveOrdersState createState() => _ReceiveOrdersState();
}

class _ReceiveOrdersState extends State<ReceiveOrders> {
  OrderBookProvider orderBookProvider;

  @override
  Widget build(BuildContext context) {
    orderBookProvider = Provider.of<OrderBookProvider>(context);
    final List<Orderbook> orderbooks =
        widget.orderbooks ?? orderBookProvider.orderbooksForCoin();

    return SimpleDialog(
      title: Text(AppLocalizations.of(context).receiveLower),
      key: const Key('receive-list-coins'),
      children: orderbooks
          .map((Orderbook orderbook) => OrderbookItem(
              key: Key('orderbook-item-${orderbook.rel.toLowerCase()}'),
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
    final OrderBookProvider orderBookProvider =
        Provider.of<OrderBookProvider>(context);
    return InkWell(
      onTap: () {
        orderBookProvider.activePair = CoinsPair(
          sell: orderBookProvider.activePair.sell,
          buy: coinsBloc.getCoinByAbbr(orderbook.rel),
        );

        if (orderbook.bids.isEmpty) {
          onCreateNoOrder(orderbook.rel);
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement<dynamic, dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => AsksOrder(
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
                'assets/${orderbook.rel.toLowerCase()}.png',
              ),
            ),
            Flexible(
              child: orderbook.bids != null && orderbook.bids.isNotEmpty
                  ? RichText(
                      text: TextSpan(
                          style: Theme.of(context).textTheme.body1,
                          children: <InlineSpan>[
                            TextSpan(
                                text: AppLocalizations.of(context).clickToSee,
                                style: Theme.of(context).textTheme.body1),
                            TextSpan(
                                text: orderbook.bids.length.toString() + ' ',
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
      this.sellAmount,
      this.onCreateOrder,
      this.onCreateNoOrder,
      this.baseCoin})
      : super(key: key);
  final double sellAmount;
  final Function(Ask) onCreateOrder;
  final Function(String) onCreateNoOrder;
  final String baseCoin;

  @override
  _AsksOrderState createState() => _AsksOrderState();
}

class _AsksOrderState extends State<AsksOrder> {
  final double headerHeight = 50;
  final double lineHeight = 50;
  bool popupSettingsVisible = false;
  OrderBookProvider orderBookProvider;
  CexProvider cexProvider;
  AddressBookProvider addressBookProvider;

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);
    orderBookProvider ??= Provider.of<OrderBookProvider>(context);
    addressBookProvider ??= Provider.of<AddressBookProvider>(context);

    final relCoin = orderBookProvider.activePair.buy.abbr;
    final List<TableRow> asksWidget = <TableRow>[];
    final Orderbook orderbook = orderBookProvider?.getOrderBook();
    List<Ask> bidsList = orderbook?.bids;

    bidsList = OrderBookProvider.sortByPrice(bidsList, quotePrice: true);
    bidsList?.asMap()?.forEach(
        (int index, Ask bid) => asksWidget.add(_tableRow(bid, index)));

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
                  child: Image.asset('assets/${relCoin.toLowerCase()}.png')),
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
                                child: Stack(
                                  children: <Widget>[
                                    Positioned(
                                      left: 6,
                                      top: 50,
                                      right: 6,
                                      bottom: 0,
                                      child: ReceiveOrdersChart(
                                        ordersList: bidsList,
                                        sellAmount: widget.sellAmount,
                                        lineHeight: lineHeight,
                                      ),
                                    ),
                                    Table(
                                      columnWidths: const {
                                        1: IntrinsicColumnWidth(),
                                      },
                                      children: [
                                        TableRow(children: [
                                          Container(
                                            height: headerHeight,
                                            alignment: const Alignment(-1, 0),
                                            padding: const EdgeInsets.only(
                                              left: 12,
                                              right: 6,
                                            ),
                                            child: Text(
                                              '${AppLocalizations.of(context).price}'
                                              ' ($relCoin)',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle
                                                  .copyWith(fontSize: 14),
                                            ),
                                          ),
                                          Container(
                                            height: headerHeight,
                                            alignment: const Alignment(1, 0),
                                            padding: const EdgeInsets.only(
                                              left: 6,
                                            ),
                                            child: Text(
                                              '${AppLocalizations.of(context).availableVolume}'
                                              ' ($relCoin)',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle
                                                  .copyWith(fontSize: 14),
                                            ),
                                          ),
                                          Container(
                                            height: headerHeight,
                                            alignment: const Alignment(1, 0),
                                            padding: const EdgeInsets.only(
                                              left: 6,
                                              right: 12,
                                            ),
                                            child: Text(
                                              '${AppLocalizations.of(context).receive.toLowerCase()}'
                                              ' ($relCoin)',
                                              textAlign: TextAlign.right,
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
                                  ],
                                ),
                              ),
                        CreateOrder(
                          onCreateNoOrder: widget.onCreateNoOrder,
                          coin: relCoin,
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
    final double cexRate = cexProvider.getCexRate() ?? 0.0;

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
          style: const TextStyle(
              fontSize: 14, color: cexColor, fontWeight: FontWeight.w400),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  TableRow _tableRow(Ask bid, int index) {
    return TableRow(
      children: [
        TableRowInkWell(
          child: Container(
            height: lineHeight,
            alignment: const Alignment(-1, 0),
            padding: const EdgeInsets.only(
              left: 12,
              right: 6,
            ),
            decoration: BoxDecoration(
                color: index % 2 > 0 ? null : Colors.white.withAlpha(10),
                border: Border(
                    top: BorderSide(
                  width: 1,
                  color: Theme.of(context).highlightColor,
                ))),
            key: Key('ask-item-$index'),
            child: Row(
              children: <Widget>[
                Text(
                  formatPrice(1 / double.parse(bid.price)),
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: 13,
                        color: Colors.greenAccent,
                      ),
                ),
                if (addressBookProvider.contactByAddress(bid.address) != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.account_circle,
                        size: 11,
                        color: Colors.white.withAlpha(150),
                      ),
                    ),
                  ),
                if (bid.isMine())
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.brightness_1,
                        size: 11,
                        color: Colors.green.withAlpha(150),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          onTap: () => _onBidTap(bid),
          onLongPress: () => _onBidLongPress(bid),
        ),
        TableRowInkWell(
          child: Container(
            height: lineHeight,
            alignment: const Alignment(1, 0),
            padding: const EdgeInsets.only(
              left: 6,
            ),
            decoration: BoxDecoration(
                color: index % 2 > 0 ? null : Colors.white.withAlpha(10),
                border: Border(
                    top: BorderSide(
                  width: 1,
                  color: Theme.of(context).highlightColor,
                ))),
            child: Text(
              formatPrice(bid.maxvolume.toDouble()),
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 13),
            ),
          ),
          onTap: () => _onBidTap(bid),
          onLongPress: () => _onBidLongPress(bid),
        ),
        TableRowInkWell(
          child: Container(
            height: lineHeight,
            alignment: const Alignment(1, 0),
            padding: const EdgeInsets.only(
              left: 6,
              right: 12,
            ),
            decoration: BoxDecoration(
                color: index % 2 > 0 ? null : Colors.white.withAlpha(10),
                border: Border(
                    top: BorderSide(
                  width: 1,
                  color: Theme.of(context).highlightColor,
                ))),
            child: Text(
              formatPrice(
                  bid.getReceiveAmount(deci(widget.sellAmount)).toDouble()),
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          onTap: () => _onBidTap(bid),
          onLongPress: () => _onBidLongPress(bid),
        )
      ],
    );
  }

  Future<void> _onBidTap(Ask bid) async {
    final bool showOrderDetailsByTap = (await SharedPreferences.getInstance())
            .getBool('showOrderDetailsByTap') ??
        true;

    showOrderDetailsByTap ? _showDetails(bid) : _createOrder(bid);
  }

  Future<void> _onBidLongPress(Ask bid) async {
    final bool showOrderDetailsByTap = (await SharedPreferences.getInstance())
            .getBool('showOrderDetailsByTap') ??
        true;

    showOrderDetailsByTap ? _createOrder(bid) : _showDetails(bid);
  }

  void _createOrder(Ask ask) {
    Navigator.of(context).pop();
    widget.onCreateOrder(ask);
  }

  void _showDetails(Ask bid) {
    setState(() {
      popupSettingsVisible = false;
    });
    _openDetailsDialog(bid);
  }

  void _openDetailsDialog(Ask bid) {
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (context) {
          return SharedPreferencesBuilder<bool>(
              pref: 'showOrderDetailsByTap',
              builder: (context, snapshot) {
                return SimpleDialog(
                  title: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      // TODO(yurii): localization
                      const Expanded(child: Text('Details')),
                      InkWell(
                        onTap: () {
                          setState(() {
                            popupSettingsVisible = !popupSettingsVisible;
                          });
                          dialogBloc.closeDialog(context);
                          _openDetailsDialog(bid);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.settings,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  titlePadding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 4,
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 8,
                    right: 0,
                    bottom: 20,
                  ),
                  children: <Widget>[
                    if (popupSettingsVisible)
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 6, 0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                // TODO(yurii): localization
                                'Open Details on single tap'
                                ' and select Order by long tap',
                                style: Theme.of(context).textTheme.body2,
                              ),
                            ),
                            !snapshot.hasData
                                ? Container()
                                : Switch(
                                    value: snapshot.data,
                                    onChanged: (bool val) async {
                                      (await SharedPreferences.getInstance())
                                          .setBool(
                                        'showOrderDetailsByTap',
                                        val,
                                      );
                                      dialogBloc.closeDialog(context);
                                      _openDetailsDialog(bid);
                                    }),
                          ],
                        ),
                      ),
                    BuildOrderDetails(
                      bid,
                      sellAmount: widget.sellAmount,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () => dialogBloc.closeDialog(context),
                          // TODO(yurii): localization
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        RaisedButton(
                          onPressed: () {
                            dialogBloc.closeDialog(context);
                            _createOrder(bid);
                          },
                          // TODO(yurii): localization
                          child: const Text('Select'),
                        )
                      ],
                    )
                  ],
                );
              });
        });
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
  const CreateOrder({this.onCreateNoOrder, this.coin});
  final Function(String) onCreateNoOrder;
  final String coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: () {
          onCreateNoOrder(coin);
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
