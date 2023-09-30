import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../dex/trade/pro/create/receive/matching_bids_chart.dart';
import '../../../../../dex/trade/pro/create/receive/matching_bids_table.dart';
import '../../../../../dex/trade/pro/create/receive/matching_orderbooks.dart';
import 'package:provider/provider.dart';
import '../../../../../../localizations.dart';
import '../../../../../../model/cex_provider.dart';
import '../../../../../../model/order_book_provider.dart';
import '../../../../../../model/orderbook.dart';
import '../../../../../authentification/lock_screen.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../widgets/cex_data_marker.dart';
import '../../../../../../../../app_config/theme_data.dart';

class MatchingBidsPage extends StatefulWidget {
  const MatchingBidsPage({
    Key key,
    this.sellAmount,
    this.onCreateOrder,
    this.onCreateNoOrder,
    this.baseCoin,
  }) : super(key: key);

  final double sellAmount;
  final Function(Ask) onCreateOrder;
  final Function(String) onCreateNoOrder;
  final String baseCoin;

  @override
  _MatchingBidsPageState createState() => _MatchingBidsPageState();
}

class _MatchingBidsPageState extends State<MatchingBidsPage> {
  static const double _headerHeight = 50;
  static const double _lineHeight = 50;
  static const int _listLimitMin = 25;
  static const int _listLimitStep = 5;
  int _listLength = 0;
  int _listLimit = 25;
  OrderBookProvider _orderBookProvider;
  CexProvider _cexProvider;

  @override
  Widget build(BuildContext context) {
    _cexProvider ??= Provider.of<CexProvider>(context);
    _orderBookProvider ??= Provider.of<OrderBookProvider>(context);

    final receiveCoin = _orderBookProvider.activePair.buy.abbr;
    final Orderbook orderbook = _orderBookProvider?.getOrderBook();
    List<Ask> bidsList = orderbook?.bids;

    bidsList = OrderBookProvider.sortByPrice(bidsList, quotePrice: true);
    setState(() {
      _listLength = bidsList?.length;
    });
    if ((_listLength ?? 0) > _listLimit)
      bidsList = bidsList.sublist(0, _listLimit);

    return LockScreen(
      context: context,
      child: Scaffold(
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
              SizedBox(
                  height: 30,
                  width: 30,
                  child: Image.asset(getCoinIconPath(receiveCoin))),
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
                        bidsList.isEmpty
                            ? Container(
                                alignment: const Alignment(0, 0),
                                padding: const EdgeInsets.only(top: 30),
                                child: Text(
                                  AppLocalizations.of(context).noMatchingOrders,
                                  style: TextStyle(
                                    fontSize: 14,
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
                                      top: _headerHeight,
                                      right: 6,
                                      bottom: 0,
                                      child: MatchingBidsChart(
                                        bidsList: bidsList,
                                        sellAmount: widget.sellAmount,
                                        lineHeight: _lineHeight,
                                      ),
                                    ),
                                    MatchingBidsTable(
                                      headerHeight: _headerHeight,
                                      lineHeight: _lineHeight,
                                      bidsList: bidsList,
                                      onCreateOrder: widget.onCreateOrder,
                                    ),
                                  ],
                                ),
                              ),
                        _buildLimitButton(),
                        CreateOrder(
                          onCreateNoOrder: widget.onCreateNoOrder,
                          coin: receiveCoin,
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
    if (_listLength < _listLimit && _listLimit == _listLimitMin)
      return SizedBox();

    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            AppLocalizations.of(context)
                .showingOrders(_listLimit, max(_listLength, _listLimit)),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          if (_listLimit > _listLimitMin)
            InkWell(
                onTap: () {
                  setState(() {
                    _listLimit -= _listLimitStep;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    AppLocalizations.of(context).less,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                )),
          if (_listLength > _listLimit)
            InkWell(
                onTap: () {
                  setState(() {
                    _listLimit += _listLimitStep;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    AppLocalizations.of(context).moreTab,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildCexRate() {
    final double cexRate = _cexProvider.getCexRate() ?? 0.0;

    if (cexRate == 0.0) return SizedBox();

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
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.light
                  ? cexColorLight.withAlpha(150)
                  : cexColor.withAlpha(150),
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
