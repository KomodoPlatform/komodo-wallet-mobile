import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CoinDetail extends StatelessWidget {
  CoinBalance coinBalance;

  CoinDetail(this.coinBalance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(coinBalance.coin.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(coinBalance.coin.name),
          Text(coinBalance.balance.address),
          QrImage(
            foregroundColor: Theme.of(context).textSelectionColor,
            data: coinBalance.balance.address,
            size: 200.0,
          ),
          Text(coinBalance.balance.balance.toString())
        ],
      ),
    );
  }
}
