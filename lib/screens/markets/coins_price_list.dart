import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/markets/build_coin_price_list_item.dart';
import 'package:komodo_dex/services/mm_service.dart';

class CoinsPriceList extends StatefulWidget {
  const CoinsPriceList({this.onItemTap});

  final Function(Coin) onItemTap;

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
                return BuildCoinPriceListItem(
                  coinBalance: snapshot.data[index],
                  onTap: () {
                    widget.onItemTap(snapshot.data[index].coin);
                  },
                );
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
