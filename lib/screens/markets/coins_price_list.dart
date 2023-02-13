import 'package:flutter/material.dart';
import '../../../generic_blocs/coins_bloc.dart';
import '../../../model/coin.dart';
import '../../../model/coin_balance.dart';
import '../markets/build_coin_price_list_item.dart';
import '../../services/mm_service.dart';

import '../../localizations.dart';

class CoinsPriceList extends StatefulWidget {
  const CoinsPriceList({this.onItemTap});

  final Function(Coin?)? onItemTap;

  @override
  _CoinsPriceListState createState() => _CoinsPriceListState();
}

class _CoinsPriceListState extends State<CoinsPriceList> {
  int touchCounter = 0;

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
        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
          final List<CoinBalance> _sortedList =
              coinsBloc.sortCoinsWithoutTestCoins(snapshot.data!);
          return _sortedList.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noCoinFound,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Listener(
                  onPointerDown: (_) {
                    setState(() {
                      touchCounter++;
                    });
                  },
                  onPointerUp: (_) {
                    setState(() {
                      touchCounter--;
                    });
                  },
                  child: ListView.builder(
                      physics: touchCounter > 1
                          ? const NeverScrollableScrollPhysics()
                          : const ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _sortedList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return BuildCoinPriceListItem(
                          key: Key('coin-' +
                              _sortedList[index].coin!.abbr!.toUpperCase()),
                          coinBalance: _sortedList[index],
                          onTap: () {
                            widget.onItemTap!(_sortedList[index].coin);
                          },
                        );
                      }),
                );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
