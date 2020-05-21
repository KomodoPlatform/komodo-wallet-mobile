import 'package:flutter/material.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
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
                    child: InkWell(
                      onTap: () {
                        widget.onTap();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: <Widget>[
                            Builder(builder: (BuildContext context) {
                              return PhotoHero(
                                radius: 18,
                                tag: 'assets/${balance.coin.toLowerCase()}.png',
                              );
                            }),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                coin.name.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle
                                    .copyWith(fontSize: 14),
                              ),
                            ),
                            _hasNonzeroPrice
                                ? Text(
                                    '\$${widget.coinBalance.priceForOne}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle
                                        .copyWith(fontSize: 18),
                                  )
                                : Container(),
                          ],
                        ),
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
