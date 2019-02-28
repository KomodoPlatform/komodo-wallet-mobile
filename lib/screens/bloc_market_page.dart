import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coin_json_bloc.dart';
import 'package:komodo_dex/blocs/orderbook_bloc.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:komodo_dex/widgets/custom_textfield.dart';

class BlocMarketPage extends StatefulWidget {
  @override
  _BlocMarketPageState createState() => _BlocMarketPageState();
}

class _BlocMarketPageState extends State<BlocMarketPage> {
  final relTxtFldCtlr = TextEditingController();
  final priceTxtFldCtlr = TextEditingController();
  Widget _buttonWaiting = Text("Buy");

  @override
  void dispose() {
    relTxtFldCtlr.dispose();
    priceTxtFldCtlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OrderbookBloc orderbookBloc = BlocProvider.of<OrderbookBloc>(context);
    final CoinJsonBloc coinJsonBloc = BlocProvider.of<CoinJsonBloc>(context);

    orderbookBloc.updateOrderbook(coinJsonBloc.baseCoin, coinJsonBloc.relCoin);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              orderbookBloc.updateOrderbook(
                  coinJsonBloc.baseCoin, coinJsonBloc.relCoin);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        children: <Widget>[
          SizedBox(height: 40),
          SelectedBaseRelCoin(),
          SizedBox(height: 40),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomTextField(
                  controller: relTxtFldCtlr,
                  labelText: 'Rel volume',
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomTextField(
                  controller: priceTxtFldCtlr,
                  labelText: 'Price',
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              RaisedButton(
                color: Theme.of(context).accentColor,
                textColor: Theme.of(context).primaryColor,
                child: _buttonWaiting,
                onPressed: () {
                  setState(() {
                    _buttonWaiting = Center(
                      child: Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme
                                      .of(context)
                                      .primaryColor))),
                    );
                  });
                  mm2
                      .postBuy(
                          coinJsonBloc.baseCoin,
                          coinJsonBloc.relCoin,
                          double.parse(relTxtFldCtlr.text),
                          double.parse(priceTxtFldCtlr.text))
                      .then((onValue) {
                    setState(() {
                      _buttonWaiting = Text("BUY");
                    });
                    if (onValue is BuyResponse && onValue.result == "success") {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                        content: new Text("Buy success, waiting for swap..."),
                      ));
                    } else {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                        content: new Text("A error happened please wait."),
                      ));
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 40),
          Text('Order Book', style: Theme.of(context).textTheme.title),
          Builder(
            builder: (context) {
              final OrderbookBloc orderbookBloc =
                  BlocProvider.of<OrderbookBloc>(context);
              return StreamBuilder<Orderbook>(
                stream: orderbookBloc.outOrderbook,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final asks = snapshot.data.asks;
                    final bids = snapshot.data.bids;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 16),
                        Text("Asks",
                            style: Theme.of(context).textTheme.subtitle),
                        SizedBox(height: 4),
                        ListOrder(orders: asks),
                        SizedBox(height: 16),
                        Text("Bids",
                            style: Theme.of(context).textTheme.subtitle),
                        SizedBox(height: 4),
                        ListOrder(orders: bids),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
}

class ListOrder extends StatefulWidget {
  const ListOrder({
    Key key,
    @required this.orders,
  }) : super(key: key);

  final List<Ask> orders;

  @override
  ListOrderState createState() {
    return new ListOrderState();
  }
}

class ListOrderState extends State<ListOrder> {
  @override
  Widget build(BuildContext context) {
    final List<TableRow> tableRows = List<TableRow>();
    tableRows.add(TableRow(children: [
      Text("Price"),
      Text("Maxvolume"),
      Text("address"),
    ]));

    widget.orders.forEach((order) {
      tableRows.add(TableRow(children: [
        Text(order.price.toString()),
        Text(order.maxvolume.toString()),
        Text(order.address),
      ]));
    });

    if (widget.orders.length > 0) {
      return Table(
        children: tableRows,
      );
    } else {
      return Text("No orders.");
    }
  }
}

class SelectedBaseRelCoin extends StatelessWidget {
  const SelectedBaseRelCoin({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Coin>>(
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
    final OrderbookBloc orderbookBloc = BlocProvider.of<OrderbookBloc>(context);

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
        _askedToLead(
            context, orderbookBloc, widget.jsonCoins.data, widget.coinJsonBloc);
      },
    );
  }

  Future<void> _askedToLead(BuildContext context, OrderbookBloc orderbookBloc,
      List<Coin> coins, CoinJsonBloc coinJsonBloc) async {
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
