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

    if (mmSe.running) coinsBloc.updateCoinBalances();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: coinsBloc.outCoins,
      builder:
          (BuildContext context, AsyncSnapshot<List<CoinBalance>> snapshot) {
        if (snapshot.data != null && snapshot.data.isNotEmpty) {
          final List<CoinBalance> _sortedList = coinsBloc.sortCoins(snapshot.data);
          return ListView.builder(
              shrinkWrap: true,
              itemCount: _sortedList.length,
              itemBuilder: (BuildContext context, int index) {
                return BuildCoinPriceListItem(
                  coinBalance: _sortedList[index],
                  onTap: () {
                    widget.onItemTap(_sortedList[index].coin);
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
