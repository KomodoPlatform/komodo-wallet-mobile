import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
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
        final zebra = <String, bool>{};
        bool zebraVal = false;
        for (CoinBalance cb in data) {
          zebra.putIfAbsent(cb.coin.abbr, () => zebraVal);
          zebraVal = !zebraVal;
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).privateKeys,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
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
                      zebra: zebra[coin] ?? false,
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
  const CoinPrivKey({Key key, this.coin, this.privKey, this.zebra})
      : super(key: key);

  final String coin;
  final String privKey;
  final bool zebra;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: zebra
          ? Theme.of(context).cardColor.withAlpha(128)
          : Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/${coin.toLowerCase()}.png',
                        width: 32,
                        height: 32,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(coin),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    copyToClipBoard(context, privKey);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: truncateMiddle(privKey),
            ),
          ],
        ),
      ),
    );
  }
}
