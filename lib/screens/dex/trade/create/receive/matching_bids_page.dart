import 'dart:math';
import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/bid_details_dialog.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/not_enough_volume_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/matching_bids_chart.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/matching_orderbooks.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';

class MatchingBidPage extends StatefulWidget {
  const MatchingBidPage(
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
  _MatchingBidPageState createState() => _MatchingBidPageState();
}

class _MatchingBidPageState extends State<MatchingBidPage> {
  final double headerHeight = 50;
  final double lineHeight = 50;
  bool popupSettingsVisible = false;
  int listLength = 0;
  int listLimit = 25;
  int listLimitMin = 25;
  int listLimitStep = 5;
  OrderBookProvider orderBookProvider;
  CexProvider cexProvider;
  AddressBookProvider addressBookProvider;

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);
    orderBookProvider ??= Provider.of<OrderBookProvider>(context);
    addressBookProvider ??= Provider.of<AddressBookProvider>(context);

    final relCoin = orderBookProvider.activePair.buy.abbr;
    final baseCoin = orderBookProvider.activePair.sell.abbr;
    final List<TableRow> asksWidget = <TableRow>[];
    final Orderbook orderbook = orderBookProvider?.getOrderBook();
    List<Ask> bidsList = orderbook?.bids;

    bidsList = OrderBookProvider.sortByPrice(bidsList, quotePrice: true);
    setState(() {
      listLength = bidsList.length;
    });
    if (bidsList.length > listLimit) bidsList = bidsList.sublist(0, listLimit);
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
                                  AppLocalizations.of(context).noMatchingOrders,
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
                                      top: headerHeight,
                                      right: 6,
                                      bottom: 0,
                                      child: MatchingBidsChart(
                                        ordersList: bidsList,
                                        sellAmount: widget.sellAmount,
                                        lineHeight: lineHeight,
                                      ),
                                    ),
                                    Table(
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
                                                  .subtitle2
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
                                              textAlign: TextAlign.end,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
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
                                              ' ($baseCoin)',
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2
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
                                                  .subtitle2
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
                        _buildLimitButton(),
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

  Widget _buildLimitButton() {
    if (listLength < listLimit && listLimit == listLimitMin) return SizedBox();

    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Showing $listLimit of ${max(listLength, listLimit)} orders. ',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          if (listLimit > listLimitMin)
            InkWell(
                onTap: () {
                  setState(() {
                    listLimit -= listLimitStep;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    'Less',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )),
          if (listLength > listLimit)
            InkWell(
                onTap: () {
                  setState(() {
                    listLimit += listLimitStep;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    'More',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )),
        ],
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
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
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
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13),
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
              formatPrice(bid.maxvolume.toDouble() * double.parse(bid.price)),
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13),
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
                  .bodyText2
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
    final double myVolume =
        ask.getReceiveAmount(deci(widget.sellAmount)).toDouble();
    final bool isEnoughVolume =
        !(ask.minVolume != null && myVolume < ask.minVolume);

    if (isEnoughVolume) {
      Navigator.of(context).pop();
      widget.onCreateOrder(ask);
    } else {
      openNotEnoughVolumeDialog(context, ask);
    }
  }

  void _showDetails(Ask bid) {
    setState(() {
      popupSettingsVisible = false;
    });
    openBidDetailsDialog(
      context: context,
      bid: bid,
      onSelect: () => _createOrder(bid),
    );
  }
}
