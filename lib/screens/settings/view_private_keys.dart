import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/get_priv_key.dart';
import 'package:komodo_dex/model/priv_key.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/utils/utils.dart';

class ViewPrivateKeys extends StatefulWidget {
  @override
  _ViewPrivateKeysState createState() => _ViewPrivateKeysState();
}

class _ViewPrivateKeysState extends State<ViewPrivateKeys> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinBalance>>(
      initialData: coinsBloc.coinBalance,
      stream: coinsBloc.outCoins,
      builder:
          (BuildContext context, AsyncSnapshot<List<CoinBalance>> snapshot) {
        if (!snapshot.hasData) return Container();
        final data = snapshot.data;
        data.sort((a, b) => a.coin.abbr.compareTo(b.coin.abbr));

        return Padding(
          padding:
              const EdgeInsets.only(top: 50, bottom: 32, right: 16, left: 16),
          child: Column(
            children: [
              Text('Private Keys'),
              SizedBox(
                height: 8.0,
              ),
              ...data.map((cb) {
                final coin = cb.coin.abbr;
                final r = MM.getPrivKey(GetPrivKey(coin: coin));
                return FutureBuilder(
                  future: r,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    final PrivKey pk = snapshot.data;

                    return CoinPrivKey(
                      coin: pk.result.coin,
                      privKey: pk.result.privKey,
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class CoinPrivKey extends StatelessWidget {
  const CoinPrivKey({Key key, this.coin, this.privKey}) : super(key: key);

  final String coin;
  final String privKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Row(
          children: [
            Image.asset(
              'assets/${coin.toLowerCase()}.png',
              width: 18,
              height: 18,
            ),
            SizedBox(
              width: 4.0,
            ),
            Text(coin),
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Text(privKey),
            ),
            SizedBox(
              width: 8.0,
            ),
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: () {
                copyToClipBoard(context, privKey);
              },
            )
          ],
        ),
      ),
    );
  }
}
