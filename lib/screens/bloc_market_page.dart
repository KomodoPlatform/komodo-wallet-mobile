import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coin_json_bloc.dart';
import 'package:komodo_dex/blocs/orderbook_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class BlocMarketPage extends StatefulWidget {
  @override
  _BlocMarketPageState createState() => _BlocMarketPageState();
}

class _BlocMarketPageState extends State<BlocMarketPage> {
  @override
  Widget build(BuildContext context) {
    final OrderbookBloc orderbookBloc = BlocProvider.of<OrderbookBloc>(context);
    final CoinJsonBloc coinJsonBloc = BlocProvider.of<CoinJsonBloc>(context);

    orderbookBloc.updateOrderbook(
                    coinJsonBloc.baseCoin, coinJsonBloc.relCoin);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 40),
        FutureBuilder<List<Coin>>(
          future: mm2.loadJsonCoins(),
          builder: (context, jsonCoins) {
            final CoinJsonBloc coinJsonBloc =
                BlocProvider.of<CoinJsonBloc>(context);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                BuildButtonCoin(
                    isBaseCoin: true,
                    coinJsonBloc: coinJsonBloc,
                    jsonCoins: jsonCoins),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("/"),
                ),
                BuildButtonCoin(
                    isBaseCoin: false,
                    coinJsonBloc: coinJsonBloc,
                    jsonCoins: jsonCoins),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child:
              Text('Orderbook', style: Theme.of(context).textTheme.title),
        ),
        Builder(
          builder: (context) {
            final OrderbookBloc orderbookBloc =
                BlocProvider.of<OrderbookBloc>(context);
            return StreamBuilder<Orderbook>(
              stream: orderbookBloc.outOrderbook,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.asks.length.toString());
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          },
        )
      ],
    );
  }
}

class BuildButtonCoin extends StatefulWidget {
  const BuildButtonCoin({
    Key key,
    @required this.coinJsonBloc,
    @required this.jsonCoins,
    @required this.isBaseCoin,
  }) : super(key: key);

  final CoinJsonBloc coinJsonBloc;
  final AsyncSnapshot<List<Coin>> jsonCoins;
  final bool isBaseCoin;

  @override
  BuildButtonCoinState createState() {
    return new BuildButtonCoinState();
  }
}

class BuildButtonCoinState extends State<BuildButtonCoin> {
  @override
  Widget build(BuildContext context) {
    final OrderbookBloc orderbookBloc =
                    BlocProvider.of<OrderbookBloc>(context);

    Stream<Coin> stream;
    if (widget.isBaseCoin) {
      stream = widget.coinJsonBloc.outBaseCoin;
    } else {
      stream = widget.coinJsonBloc.outRelCoin;
    }

    return RaisedButton(
      child: StreamBuilder<Coin>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData && widget.jsonCoins.hasData) {
            return Text(snapshot.data.abbr);
          } else if (widget.isBaseCoin) {
            return Text(widget.coinJsonBloc.baseCoin.abbr);
          } else {
            return Text(widget.coinJsonBloc.relCoin.abbr);
          }
        },
      ),
      onPressed: () {
        _askedToLead(context, orderbookBloc, widget.jsonCoins.data, widget.coinJsonBloc);
      },
    );
  }

  Future<void> _askedToLead(
      BuildContext context, OrderbookBloc orderbookBloc, List<Coin> coins, CoinJsonBloc coinJsonBloc) async {
    await showDialog<List<Coin>>(
        context: context,
        builder: (BuildContext context) {
          List<SimpleDialogOption> listDialog = new List<SimpleDialogOption>();
          coins.forEach((coin) {
            SimpleDialogOption dialogItem = SimpleDialogOption(
              onPressed: () {
                if (widget.isBaseCoin)
                  coinJsonBloc.updateBaseCoin(coin);
                else
                  coinJsonBloc.updateRelCoin(coin);

                orderbookBloc.updateOrderbook(
                    coinJsonBloc.baseCoin, coinJsonBloc.relCoin);
                Navigator.pop(context);
              },
              child: Text(coin.abbr),
            );
            listDialog.add(dialogItem);
          });
          return Theme(
            data: ThemeData(
                textTheme: Theme.of(context).textTheme,
                dialogBackgroundColor: Theme.of(context).dialogBackgroundColor),
            child: SimpleDialog(
              title: Text(widget.isBaseCoin
                  ? 'Select the base coin'
                  : 'Select the rel coin'),
              children: listDialog,
            ),
          );
        });
  }
}
