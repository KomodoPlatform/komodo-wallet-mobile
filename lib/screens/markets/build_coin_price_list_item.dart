import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';

import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/markets/candlestick_chart.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/small_button.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

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
  String chartDuration = '3600';
  CexProvider cexProvider;

  @override
  Widget build(BuildContext context) {
    cexProvider = Provider.of<CexProvider>(context);
    final bool _hasNonzeroPrice =
        double.parse(widget.coinBalance.priceForOne ?? '0') > 0;
    coin = widget.coinBalance.coin;
    balance = widget.coinBalance.balance;

    final bool _hasChartData =
        cexProvider.isChartsAvailable('${widget.coinBalance.coin.abbr}-USDC');

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
                                                expanded
                                                    ? Icons.unfold_less
                                                    : Icons.unfold_more,
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
            child: FutureBuilder<ChartData>(
              future: cexProvider
                  .getCandles('${widget.coinBalance.coin.abbr}-USDC'),
              builder:
                  (BuildContext context, AsyncSnapshot<ChartData> snapshot) {
                List<CandleData> candles;
                if (snapshot.hasData) {
                  candles = snapshot.data.data[chartDuration];
                  if (candles == null) {
                    chartDuration = snapshot.data.data.keys.first;
                    candles = snapshot.data.data[chartDuration];
                  }
                }

                return Column(
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
                              onPressed: snapshot.hasData
                                  ? () {
                                      setState(() {
                                        quotedChart = !quotedChart;
                                      });
                                    }
                                  : null,
                              child: Text(
                                quotedChart
                                    ? 'USDC/${widget.coinBalance.coin.abbr}'
                                    : '${widget.coinBalance.coin.abbr}/USDC',
                                style: const TextStyle(fontSize: 12),
                              )),
                          Expanded(child: Container()),
                          SmallButton(
                            onPressed: snapshot.hasData
                                ? () {
                                    _buildDurationDialog(
                                        snapshot.data.data.keys.toList());
                                  }
                                : null,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  _durations[chartDuration] ?? 'duration',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: chartHeight,
                        child: snapshot.hasData
                            ? CandleChart(
                                data: candles,
                                duration: int.parse(chartDuration),
                                candleWidth: 8,
                                strokeWidth: 1,
                                textColor:
                                    const Color.fromARGB(200, 255, 255, 255),
                                gridColor:
                                    const Color.fromARGB(50, 255, 255, 255),
                                upColor: Colors.green,
                                downColor: Colors.red,
                                filled: true,
                                quoted: quotedChart,
                              )
                            : snapshot.hasError
                                ? const Center(
                                    child: Text(
                                        'Something went wrong. Try again later.'), // TODO(yurii): localization
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _buildDurationDialog(List<String> durations) {
    final List<SimpleDialogOption> options = [];

    for (String duration in durations) {
      if (_durations[duration] != null) {
        options.add(
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                chartDuration = duration;
                dialogBloc.closeDialog(context);
              });
            },
            child: Row(
              children: <Widget>[
                Icon(
                  duration == chartDuration
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: duration == chartDuration
                      ? Theme.of(context).accentColor
                      : null,
                ),
                const SizedBox(width: 4),
                Text(
                  _durations[duration] ?? '${duration}s',
                  style: TextStyle(
                      color: duration == chartDuration
                          ? Theme.of(context).accentColor
                          : null),
                ),
              ],
            ),
          ),
        );
      }
    }

    dialogBloc.dialog = showDialog<String>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Duration'),
            children: options,
          );
        });
  }
}

Map<String, String> _durations = {
  '60': '1min',
  '180': '3min',
  '300': '5min',
  '900': '15min',
  '1800': '30min',
  '3600': '1hour',
  '7200': '2hours',
  '14400': '4hours',
  '21600': '6hours',
  '43200': '12hours',
  '86400': '24hours',
};
