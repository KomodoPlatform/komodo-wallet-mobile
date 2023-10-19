import 'package:flutter/material.dart';
import '../../blocs/coins_bloc.dart';
import '../../blocs/dialog_bloc.dart';
import '../../localizations.dart';
import '../../model/coin_balance.dart';
import '../../model/get_priv_key.dart';
import '../../model/priv_key.dart';
import '../../services/mm.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_simple_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ViewPrivateKeys extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinBalance>>(
      initialData: coinsBloc.coinBalance,
      stream: coinsBloc.outCoins,
      builder:
          (BuildContext context, AsyncSnapshot<List<CoinBalance>> snapshot) {
        if (!snapshot.hasData) return SizedBox();
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
              ...data.map(
                (cb) {
                  final coin = cb.coin.abbr;
                  return CoinPrivKey(
                    coin: coin,
                    zebra: zebra[coin] ?? false,
                  );
                },
              ).toList(),
            ],
          ),
        );
      },
    );
  }
}

class CoinPrivKey extends StatefulWidget {
  const CoinPrivKey({Key key, this.coin, this.zebra}) : super(key: key);

  final String coin;
  final bool zebra;

  @override
  _CoinPrivKeyState createState() => _CoinPrivKeyState();
}

class _CoinPrivKeyState extends State<CoinPrivKey> {
  BuildContext mContext;

  @override
  Widget build(BuildContext context) {
    setState(() => mContext = context);

    return Material(
        color: widget.zebra
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).cardColor,
        child: InkWell(
          onTap: () {
            dialogBloc.dialog = showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return CustomSimpleDialog(
                  children: [
                    _buildDialogContent(),
                  ],
                );
              },
            ).then((dynamic data) {
              dialogBloc.dialog = null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          getCoinIconPath(widget.coin),
                          width: 32,
                          height: 32,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(widget.coin),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    Icon(Icons.more_vert),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildDialogContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width * 0.9,
      child: FutureBuilder<PrivKey>(
          future: MM.getPrivKey(GetPrivKey(coin: widget.coin)),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            String getPrivKey() => snapshot.data.result.privKey;

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            getCoinIconPath(widget.coin),
                            width: 16,
                            height: 16,
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(widget.coin),
                          SizedBox(
                            width: 6.0,
                          ),
                          Text(AppLocalizations.of(context).privateKey + ':')
                        ],
                      ),
                      SizedBox(height: 16),
                      QrImage(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        data: getPrivKey(),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          shareText(getPrivKey());
                          Future.delayed(Duration(seconds: 2), () {
                            ScaffoldMessenger.of(mContext)
                                .hideCurrentSnackBar();
                          });
                        },
                        child: Text(getPrivKey(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(fontFamily: 'monospace')),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).close),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}
