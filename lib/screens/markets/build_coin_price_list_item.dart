import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/markets/candlestick_chart.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/small_button.dart';
import 'package:komodo_dex/widgets/theme_data.dart';

class BuildCoinPriceListItem extends StatefulWidget {
  const BuildCoinPriceListItem({this.coinBalance, this.onTap});

  final CoinBalance coinBalance;
  final Function onTap;

  @override
  _BuildCoinPriceListItemState createState() => _BuildCoinPriceListItemState();
}

class _BuildCoinPriceListItemState extends State<BuildCoinPriceListItem> {
  Coin coin;
  Balance balance;
  bool expanded = false;
  bool fetching = false; // TODO(yurii): will get flag from CexProvider
  bool quotedChart = false;

  @override
  Widget build(BuildContext context) {
    final bool _hasNonzeroPrice =
        double.parse(widget.coinBalance.priceForOne ?? '0') > 0;
    coin = widget.coinBalance.coin;
    balance = widget.coinBalance.balance;

    // TODO(yurii): check if have charts data here
    final bool _hasChartData = _hasNonzeroPrice;

    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                color: Color(int.parse(coin.colorCoin)),
                width: 8,
                height: 64,
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Material(
                        color: Theme.of(context).primaryColor,
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: InkWell(
                                onTap: widget.onTap,
                                child: Container(
                                  height: 64,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  child: Row(
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                            'assets/${balance.coin.toLowerCase()}.png'),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        coin.name.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle
                                            .copyWith(fontSize: 14),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    expanded = !expanded;
                                  });
                                },
                                child: Container(
                                  height: 64,
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 14,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      if (_hasNonzeroPrice)
                                        Row(
                                          children: <Widget>[
                                            CexMarker(
                                              context,
                                              size: const Size.fromHeight(14),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              '\$${widget.coinBalance.priceForOne}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle
                                                  .copyWith(
                                                      color: cexColor,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      Container(
                                        width: 8,
                                        child: _hasChartData
                                            ? Icon(
                                                Icons.arrow_drop_down,
                                                color: cexColor,
                                                size: 20,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (expanded && _hasChartData) _buildChart(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    const double controlsBarHeight = 60;
    final double chartHeight = MediaQuery.of(context).size.height / 2;

    return Container(
      color: Theme.of(context).backgroundColor,
      height: controlsBarHeight + chartHeight,
      child: Row(
        children: <Widget>[
          Opacity(
            opacity: 0.3,
            child: Container(
              color: Color(int.parse(coin.colorCoin)),
              width: 8,
              height: controlsBarHeight + chartHeight,
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: controlsBarHeight,
                  padding: const EdgeInsets.only(
                    left: 2,
                    right: 2,
                  ),
                  child: Row(
                    children: <Widget>[
                      SmallButton(
                          onPressed: fetching
                              ? null
                              : () {
                                  setState(() {
                                    quotedChart = !quotedChart;
                                  });
                                },
                          child: Text(
                            quotedChart
                                ? '${widget.coinBalance.coin.abbr}/USD'
                                : 'USD/${widget.coinBalance.coin.abbr}',
                            style: const TextStyle(fontSize: 12),
                          )),
                      const SizedBox(width: 5),
                      SmallButton(
                        onPressed: fetching ? null : () {},
                        child: Row(
                          children: <Widget>[
                            const Text(
                              '5min',
                              style: TextStyle(fontSize: 12),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      SmallButton(
                        onPressed: fetching ? null : () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(
                              Icons.refresh,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Updated: 1m',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: chartHeight,
                  child: FutureBuilder<List<CandleData>>(
                      future: _getOHLCData(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<CandleData>> snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.data == null) {
                          return const Center(
                              child: Text('Something went wrong...'));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                height: chartHeight,
                                child: CandleChart(
                                  snapshot.data,
                                  candleWidth: 8,
                                  strokeWidth: 1,
                                  textColor:
                                      const Color.fromARGB(200, 255, 255, 255),
                                  gridColor:
                                      const Color.fromARGB(50, 255, 255, 255),
                                  upColor: Colors.green,
                                  downColor: Colors.red,
                                  filled: true,
                                  allowDynamicRescale: true,
                                  quoted: quotedChart,
                                )),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<CandleData>> _getOHLCData() async {
  http.Response _res;
  String _body;
  try {
    _res = await http.get('http://komodo.live:3333/api/v1/ohlc/kmd-btc');
    _body = _res.body;
  } catch (e) {
    print('Failed to fetch data: $e');
    rethrow;
  }

  dynamic json;
  try {
    json = jsonDecode(_body);
  } catch (e) {
    print('Failed to parse json: $e');
    rethrow;
  }

  if (json == null) return null;

  final List<CandleData> _data = [];

  final List<dynamic> list = json['14400'];
  for (var candle in list) {
    final CandleData _candleData = CandleData(
      closeTime: candle['timestamp'],
      openPrice: candle['open'].toDouble(),
      highPrice: candle['high'].toDouble(),
      lowPrice: candle['low'].toDouble(),
      closePrice: candle['close'].toDouble(),
      volume: candle['volume'].toDouble(),
      quoteVolume: candle['quote_volume'].toDouble(),
    );
    _data.add(_candleData);
  }

  return _data;
}
