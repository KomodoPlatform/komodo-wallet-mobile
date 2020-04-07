import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/services/mm_service.dart';

import 'build_coin_price.dart';

class CoinsPriceList extends StatefulWidget {
  @override
  _CoinsPriceListState createState() => _CoinsPriceListState();
}

class _CoinsPriceListState extends State<CoinsPriceList> {
  @override
  void initState() {
    super.initState();

    if (MMService().running) {
      coinsBloc.loadCoin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: coinsBloc.outCoins,
      builder:
          (BuildContext context, AsyncSnapshot<List<CoinBalance>> snapshot) {
        if (snapshot.data != null && snapshot.data.isNotEmpty) {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return BuildCoinPrice(snapshot.data[index]);
              });
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
