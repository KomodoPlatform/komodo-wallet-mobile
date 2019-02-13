import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/coin_detail.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class BlocCoinsPage extends StatefulWidget {
  @override
  _BlocCoinsPageState createState() => _BlocCoinsPageState();
}

class _BlocCoinsPageState extends State<BlocCoinsPage> {

  @override
  Widget build(BuildContext context) {
    final CoinsBloc coinsBloc = BlocProvider.of<CoinsBloc>(context);
    coinsBloc.updateBalanceForEachCoin();

    return Container(
        child: StreamBuilder<List<CoinBalance>>(
    stream: coinsBloc.outCoins,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              Coin item = snapshot.data[index].coin;
              Balance balance = snapshot.data[index].balance;

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CoinDetail(snapshot.data[index])),
                  );
                },
                subtitle: Text(
                  item.name,
                  style: Theme.of(context).textTheme.body1,
                ),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      balance.balance.toString(),
                      style: Theme.of(context).textTheme.title,
                      textAlign: TextAlign.end,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                      child: Text(
                        item.abbr,
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ],
                ),
              );
            });
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
        ),
      );
  }
}