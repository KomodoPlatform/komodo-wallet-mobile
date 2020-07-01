import 'package:flutter/material.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final bool _hasNonzeroPrice =
        double.parse(widget.coinBalance.priceForOne ?? '0') > 0;
    coin = widget.coinBalance.coin;
    balance = widget.coinBalance.balance;

    return Container(
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            color: Color(int.parse(coin.colorCoin)),
            width: 8,
          ),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Material(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: InkWell(
                              onTap: widget.onTap,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, top: 14, bottom: 14),
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
                            ),
                          )),
                          _hasNonzeroPrice
                              ? Row(
                                  children: <Widget>[
                                    CexMarker(context),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      '\$${widget.coinBalance.priceForOne}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle
                                          .copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                )
                              : Container(),
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
    );
  }
}
