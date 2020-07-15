import 'package:flutter/material.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/candlestick_chart.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:komodo_dex/screens/markets/order_book_chart.dart';
import 'package:komodo_dex/screens/markets/order_book_table.dart';
import 'package:komodo_dex/widgets/duration_select.dart';
import 'package:provider/provider.dart';

class OrderBookPage extends StatefulWidget {
  const OrderBookPage();

  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  OrderBookProvider _orderBookProvider;
  CexProvider _cexProvider;
  bool _hasBothCoins = false;
  bool _hasChartsData = false;
  String _pairStr;
  bool _showChart = false;
  String _chartDuration = '3600';
  List<String> _durationData;

  @override
  Widget build(BuildContext context) {
    _orderBookProvider = Provider.of<OrderBookProvider>(context);
    _cexProvider = Provider.of<CexProvider>(context);
    _hasBothCoins = _orderBookProvider.activePair?.sell != null &&
        _orderBookProvider.activePair?.buy != null;
    _pairStr = _hasBothCoins
        ? '${_orderBookProvider.activePair.buy.abbr}-${_orderBookProvider.activePair.sell.abbr}'
        : null;
    _hasChartsData = _hasBothCoins && _cexProvider.isChartsAvailable(_pairStr);

    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: _buildPairSelect(),
            ),
            if (_hasChartsData)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: _buildTabsButtons(),
              ),
            if (_showChart) _buildCandleChart(),
            if (!_showChart) _buildOrderBook(),
          ],
        ),
      ),
    );
  }

  Widget _buildPairSelect() {
    return Container(
      child: Card(
        elevation: 8,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CoinSelect(
                  value: _orderBookProvider.activePair?.buy,
                  type: CoinType.base,
                  pairedCoin: _orderBookProvider.activePair?.sell,
                  autoOpen: _orderBookProvider.activePair?.buy == null &&
                      _orderBookProvider.activePair?.sell != null,
                  compact: MediaQuery.of(context).size.width < 360,
                  hideInactiveCoins: false,
                  onChange: (Coin value) {
                    setState(() {
                      _showChart = false;
                    });
                    _orderBookProvider.activePair = CoinsPair(
                      buy: value,
                      sell: _orderBookProvider.activePair?.sell,
                    );
                  }),
              const SizedBox(width: 12),
              ButtonTheme(
                minWidth: 40,
                child: FlatButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      _orderBookProvider.activePair = CoinsPair(
                        buy: _orderBookProvider.activePair?.sell,
                        sell: _orderBookProvider.activePair?.buy,
                      );
                    },
                    child: Icon(Icons.swap_horiz)),
              ),
              const SizedBox(width: 12),
              CoinSelect(
                value: _orderBookProvider.activePair?.sell,
                type: CoinType.rel,
                pairedCoin: _orderBookProvider.activePair?.buy,
                autoOpen: _orderBookProvider.activePair?.sell == null &&
                    _orderBookProvider.activePair?.buy != null,
                compact: MediaQuery.of(context).size.width < 360,
                hideInactiveCoins: false,
                onChange: (Coin value) {
                  setState(() {
                    _showChart = false;
                  });
                  _orderBookProvider.activePair = CoinsPair(
                    sell: value,
                    buy: _orderBookProvider.activePair?.buy,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabsButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (_showChart)
          DurationSelect(
            value: _chartDuration,
            options: _durationData,
            disabled: _durationData == null,
            onChange: (String value) {
              setState(() {
                _chartDuration = value;
              });
            },
          ),
        Expanded(child: Container()),
        FlatButton(
            onPressed: () {
              setState(() {
                _showChart = true;
              });
            },
            child: Text(
              'Chart', // TODO(yurii): localization
              style: _showChart
                  ? TextStyle(
                      color: Theme.of(context).accentColor,
                    )
                  : null,
            )),
        FlatButton(
            onPressed: () {
              setState(() {
                _showChart = false;
              });
            },
            child: Text(
              'Depth', // TODO(yurii): localization
              style: !_showChart
                  ? TextStyle(
                      color: Theme.of(context).accentColor,
                    )
                  : null,
            )),
      ],
    );
  }

  Widget _buildCandleChart() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        child: FutureBuilder<ChartData>(
          future: _cexProvider.getCandles(_pairStr),
          builder: (
            BuildContext context,
            AsyncSnapshot<ChartData> snapshot,
          ) {
            if (!snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _durationData = null;
                });
              });
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _durationData = snapshot.data.data.keys.toList();
              });
            });

            return CandleChart(
              data: snapshot.data.data[_chartDuration],
              duration: int.parse(_chartDuration),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderBook() {
    if (!_hasBothCoins) {
      return const Center(
        heightFactor: 10,
        child: Text('Please select coins'), // TODO(yurii): localization
      );
    }

    Orderbook _pairOrderBook;

    try {
      _pairOrderBook = _orderBookProvider.getOrderBook();
    } catch (_) {}

    if (_pairOrderBook == null) {
      return const Center(heightFactor: 10, child: CircularProgressIndicator());
    }

    final List<Ask> _sortedAsks =
        OrderBookProvider.sortByPrice(_pairOrderBook.asks);
    final List<Ask> _sortedBids =
        OrderBookProvider.sortByPrice(_pairOrderBook.bids, quotePrice: true);

    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            OrderBookChart(
              sortedAsks: _sortedAsks,
              sortedBids: _sortedBids,
            ),
            OrderBookTable(
              sortedAsks: _sortedAsks,
              sortedBids: _sortedBids,
            ),
          ],
        ),
      ],
    );
  }
}
