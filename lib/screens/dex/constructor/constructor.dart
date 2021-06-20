import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/dex/constructor/buy_form.dart';
import 'package:komodo_dex/screens/dex/constructor/coins_list.dart';
import 'package:komodo_dex/screens/dex/constructor/sell_form.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:provider/provider.dart';

class SwapConstructor extends StatefulWidget {
  @override
  _SwapConstructorState createState() => _SwapConstructorState();
}

class _SwapConstructorState extends State<SwapConstructor> {
  OrderBookProvider _obProvider;
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _obProvider ??= Provider.of<OrderBookProvider>(context);
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    return FutureBuilder(
      future: _subscribeDepths(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildProgress();

        return Container(
          padding: EdgeInsets.fromLTRB(12, 12, 0, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSell()),
                    SizedBox(width: 12),
                    Expanded(child: _buildBuy()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sell:',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        SizedBox(height: 6),
        Flexible(
          child: Stack(
            overflow: Overflow.visible,
            children: [
              _constrProvider.sellCoin == null
                  ? CoinsList(type: CoinType.base)
                  : SellForm(),
              Positioned(
                child: Container(
                  color: Theme.of(context).primaryColor,
                ),
                right: -1,
                width: 2,
                top: 0,
                bottom: 0,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBuy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buy:',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        SizedBox(height: 6),
        Flexible(
            child: Stack(
          overflow: Overflow.visible,
          children: [
            _constrProvider.buyCoin == null
                ? CoinsList(type: CoinType.rel)
                : BuyForm(),
            Positioned(
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
              left: -13,
              width: 2,
              top: 0,
              bottom: 0,
            )
          ],
        ))
      ],
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<bool> _subscribeDepths() async {
    final List<Coin> active =
        coinsBloc.coinBalance.map((bal) => bal.coin).toList();
    for (Coin coin in active) {
      await _obProvider.subscribeDepth(coin, CoinType.base);
      await _obProvider.subscribeDepth(coin, CoinType.rel);
    }

    return true;
  }
}
