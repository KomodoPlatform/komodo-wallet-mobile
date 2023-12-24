import 'package:flutter/material.dart';
import '../../localizations.dart';
import '../../model/addressbook_provider.dart';
import '../../model/cex_provider.dart';

import '../../model/order_book_provider.dart';
import '../../model/orderbook.dart';
import '../markets/order_details_page.dart';
import '../../utils/utils.dart';
import '../../widgets/cex_data_marker.dart';
import '../../app_config/theme_data.dart';
import 'package:provider/provider.dart';

class OrderBookTable extends StatefulWidget {
  const OrderBookTable({
    @required this.sortedAsks,
    @required this.sortedBids,
  });

  final List<Ask> sortedAsks;
  final List<Ask> sortedBids;

  @override
  _OrderBookTableState createState() => _OrderBookTableState();
}

class _OrderBookTableState extends State<OrderBookTable> {
  OrderBookProvider orderBookProvider;
  CexProvider cexProvider;
  AddressBookProvider addressBookProvider;

  @override
  Widget build(BuildContext context) {
    orderBookProvider ??= Provider.of<OrderBookProvider>(context);
    cexProvider ??= Provider.of<CexProvider>(context);
    addressBookProvider ??= Provider.of<AddressBookProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Table(
        key: const Key('order-book-table'),
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.0),
        },
        children: [
          _buildTableHeader(),
          _buildSpacer(),
          ..._buildAsksList(),
          _buildCexRate(),
          ..._buildBidsList(),
        ],
      ),
    );
  }

  void _showOrderDetails(Ask order) {
    Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => OrderDetailsPage(
                  order: order,
                )));
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      children: [
        Container(
          height: 34,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            AppLocalizations.of(context)
                .ordersTablePrice(orderBookProvider.activePair.buy.abbr),
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Container(
          height: 34,
          alignment: Alignment.centerRight,
          child: Text(
            AppLocalizations.of(context)
                .ordersTableAmount(orderBookProvider.activePair.sell.abbr),
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 4),
          height: 34,
          alignment: Alignment.centerRight,
          child: Text(
            AppLocalizations.of(context)
                .ordersTableAmount(orderBookProvider.activePair.buy.abbr),
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildBidsList() {
    final List<Ask> _sortedBids = List.from(widget.sortedBids);
    final List<TableRow> _bidsList = [];

    for (int i = 0; i < _sortedBids.length; i++) {
      final Ask bid = _sortedBids[i];

      final double _bidVolume = bid.maxvolume.toDouble();

      final double convertedVolume = _bidVolume / bid.priceRat.toDouble();

      _bidsList.add(TableRow(
        children: <Widget>[
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Container(
              height: 26,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: <Widget>[
                  Text(
                    formatPrice((1 / double.parse(bid.price)).toString()),
                    maxLines: 1,
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                  if (_isInAdressBook(bid.address))
                    Container(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.account_circle,
                        size: 11,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withAlpha(150),
                      ),
                    ),
                  if (bid.isMine())
                    Container(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.brightness_1,
                        size: 11,
                        color: Colors.green.withAlpha(150),
                      ),
                    ),
                ],
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Container(
              height: 26,
              alignment: Alignment.centerRight,
              child: Text(
                formatPrice(_bidVolume.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withAlpha(150),
                    fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Container(
              height: 26,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                formatPrice(convertedVolume.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withAlpha(150),
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ));
    }
    if (_bidsList.isEmpty) {
      _bidsList.add(TableRow(
        children: [
          Container(
            height: 26,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              AppLocalizations.of(context).marketsNoBids,
              maxLines: 1,
              style: const TextStyle(color: Colors.green, fontSize: 14),
            ),
          ),
          SizedBox(),
          SizedBox(),
        ],
      ));
    }

    return _bidsList;
  }

  List<TableRow> _buildAsksList() {
    final List<Ask> _sortedAsks = widget.sortedAsks;
    List<TableRow> _asksList = [];

    for (int i = 0; i < _sortedAsks.length; i++) {
      final Ask ask = _sortedAsks[i];
      final convertedVolume =
          ask.maxvolume.toDouble() * ask.priceRat.toDouble();

      _asksList.add(TableRow(
        children: <Widget>[
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Container(
              height: 26,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: <Widget>[
                  Text(
                    formatPrice(ask.price),
                    maxLines: 1,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                  if (_isInAdressBook(ask.address))
                    Container(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.account_circle,
                        size: 11,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withAlpha(150),
                      ),
                    ),
                  if (ask.isMine())
                    Container(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.brightness_1,
                        size: 11,
                        color: Colors.red.withAlpha(150),
                      ),
                    ),
                ],
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Container(
              height: 26,
              alignment: Alignment.centerRight,
              child: Text(
                formatPrice(ask.maxvolume.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withAlpha(150),
                    fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Container(
              height: 26,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                formatPrice(convertedVolume.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withAlpha(150),
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ));
    }
    _asksList = List.from(_asksList.reversed);
    if (_asksList.isEmpty) {
      _asksList.add(TableRow(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 26,
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              AppLocalizations.of(context).marketsNoAsks,
              maxLines: 1,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
          SizedBox(),
          SizedBox(),
        ],
      ));
    }

    return _asksList;
  }

  TableRow _buildCexRate() {
    final double cexRate = cexProvider.getCexRate() ?? 0.0;

    return TableRow(
      children: [
        cexRate > 0
            ? SizedBox(
                height: 26,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      bottom: 0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? cexColorLight.withAlpha(50)
                                  : cexColor.withAlpha(50),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                            ),
                            padding: const EdgeInsets.only(
                              left: 4,
                              right: 4,
                              top: 2,
                              bottom: 2,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  formatPrice(cexRate),
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w100,
                                      ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                CexMarker(
                                  context,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? cexColorLight
                                      : cexColor,
                                  size: const Size.fromHeight(12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            '≈ ${cexProvider.convert(cexRate, from: orderBookProvider.activePair.buy.abbr)}',
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cexColorLight
                                    : cexColor,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(),
        const SizedBox(height: 26),
        const SizedBox(height: 26),
      ],
    );
  }

  TableRow _buildSpacer() {
    return const TableRow(
      children: [
        SizedBox(height: 12),
        SizedBox(height: 12),
        SizedBox(height: 12),
      ],
    );
  }

  bool _isInAdressBook(String address) {
    return addressBookProvider.contactByAddress(address) != null;
  }
}
