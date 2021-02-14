import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/matching_orderbook_item.dart';
import 'package:provider/provider.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';

class MatchingOrderbooks extends StatefulWidget {
  const MatchingOrderbooks({
    Key key,
    this.sellAmount,
    this.onCreateNoOrder,
    this.onCreateOrder,
    this.orderbooks,
  }) : super(key: key);

  final double sellAmount;
  final Function(String) onCreateNoOrder;
  final Function(Ask) onCreateOrder;
  final List<Orderbook> orderbooks; // for integration tests

  @override
  _MatchingOrderbooksState createState() => _MatchingOrderbooksState();
}

class _MatchingOrderbooksState extends State<MatchingOrderbooks> {
  OrderBookProvider orderBookProvider;
  final searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    orderBookProvider = Provider.of<OrderBookProvider>(context);
    final List<Orderbook> orderbooks =
        widget.orderbooks ?? orderBookProvider.orderbooksForCoin();

    return SimpleDialog(
      title: Text(AppLocalizations.of(context).receiveLower),
      key: const Key('receive-list-coins'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: searchTextController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search for Ticker',
              counterText: '',
            ),
            maxLength: 16,
          ),
        ),
        ...orderbooks
            .where((ob) =>
                (ob.base != null && ob.base.isNotEmpty) &&
                (ob.rel != null && ob.rel.isNotEmpty))
            .where((ob) => ob.rel
                .toLowerCase()
                .startsWith(searchTextController.text.toLowerCase()))
            .map((Orderbook orderbook) => MatchingOrderbookItem(
                key: ValueKey('orderbook-item-${orderbook.rel.toLowerCase()}'),
                orderbook: orderbook,
                onCreateNoOrder: widget.onCreateNoOrder,
                onCreateOrder: widget.onCreateOrder,
                sellAmount: widget.sellAmount))
            .toList(),
      ],
    );
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }
}

class CreateOrder extends StatelessWidget {
  const CreateOrder({this.onCreateNoOrder, this.coin});
  final Function(String) onCreateNoOrder;
  final String coin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: () {
          onCreateNoOrder(coin);
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_circle,
                size: 30,
                color: Theme.of(context).accentColor,
              ),
              const SizedBox(
                width: 16,
              ),
              Text(
                AppLocalizations.of(context).noOrderAvailable,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).accentColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
