import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';

import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/markets/candlestick_chart.dart';
import 'package:komodo_dex/widgets/candles_icon.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/duration_select.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
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
  String _currency;

  @override
  Widget build(BuildContext context) {
    cexProvider = Provider.of<CexProvider>(context);
    final bool _hasNonzeroPrice =
        double.parse(widget.coinBalance.priceForOne ?? '0') > 0;
    coin = widget.coinBalance.coin;
    balance = widget.coinBalance.balance;

    _currency = cexProvider.currency.toLowerCase() == 'usd'
        ? 'USDC'
        : cexProvider.currency.toUpperCase();
    final bool _hasChartData = cexProvider
        .isChartAvailable('${widget.coinBalance.coin.abbr}-$_currency');

    return Column(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.all(0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: InkWell(
                          onTap: widget.onTap,
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: AssetImage(
                                      'assets/coin-icons/${balance.coin.toLowerCase()}.png'),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  coin.name.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                        cexProvider.convert(double.parse(
                                          widget.coinBalance.priceForOne,
                                        )),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2
                                            .copyWith(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? cexColorLight
                                                    : cexColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                Container(
                                  child: _hasNonzeroPrice && _hasChartData
                                      ? CandlesIcon(
                                          size: 14,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? cexColorLight
                                              : cexColor.withOpacity(0.8),
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
                ],
              ),
            ),
          ],
        ),
        if (expanded && _hasChartData) _buildChart(),
      ],
    );
  }

  Widget _buildChart() {
    const double controlsBarHeight = 60;
    final double chartHeight = MediaQuery.of(context).size.height / 2;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
              future: cexProvider.getCandles(
                '${widget.coinBalance.coin.abbr}-$_currency',
                double.parse(chartDuration),
              ),
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

                List<Widget> _buildDisclaimer() {
                  if (!snapshot.hasData || snapshot.data.chain.length < 2)
                    return [];

                  final String mediateBase = snapshot.data.chain[0].reverse
                      ? snapshot.data.chain[0].rel.toUpperCase()
                      : snapshot.data.chain[0].base.toUpperCase();

                  return [
                    const SizedBox(width: 4),
                    Text(
                      '(based on ${widget.coinBalance.coin.abbr}/$mediateBase)',
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? cexColorLight
                                  : cexColor),
                    )
                  ];
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
                          DurationSelect(
                            value: chartDuration,
                            options: snapshot.data?.data?.keys?.toList(),
                            disabled: !snapshot.hasData,
                            onChange: (String value) {
                              setState(() {
                                chartDuration = value;
                              });
                            },
                          ),
                          ..._buildDisclaimer(),
                          Expanded(child: SizedBox()),
                          ElevatedButton(
                              onPressed: snapshot.hasData
                                  ? () {
                                      setState(() {
                                        quotedChart = !quotedChart;
                                      });
                                    }
                                  : null,
                              style: elevatedButtonSmallButtonStyle(),
                              child: Text(
                                quotedChart
                                    ? '$_currency/${widget.coinBalance.coin.abbr}'
                                    : '${widget.coinBalance.coin.abbr}/$_currency',
                                style: const TextStyle(fontSize: 12),
                              )),
                        ],
                      ),
                    ),
                    Container(
                        height: chartHeight,
                        clipBehavior: Clip.hardEdge,
                        // `decoration` required if `clipBehavior != null`
                        decoration: BoxDecoration(),
                        child: snapshot.hasData
                            ? CandleChart(
                                data: candles,
                                duration: int.parse(chartDuration),
                                quoted: quotedChart,
                                textColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                                gridColor: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black.withOpacity(.2)
                                    : Colors.white.withOpacity(.4))
                            : snapshot.hasError
                                ? Center(
                                    child: Text(AppLocalizations.of(context)
                                        .candleChartError),
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
}
