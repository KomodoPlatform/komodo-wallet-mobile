import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import '../../../../../blocs/coins_bloc.dart';
import '../../../../../model/coin.dart';
import '../../../../../model/coin_balance.dart';
import '../../../../../model/market.dart';
import '../../../../../model/order_book_provider.dart';
import '../../../../../model/swap_constructor_provider.dart';
import '../../../../dex/trade/simple/create/empty_list_message.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/auto_scroll_text.dart';
import 'package:provider/provider.dart';

class CoinsListAll extends StatefulWidget {
  const CoinsListAll({this.type, this.searchTerm});

  final Market type;
  final String searchTerm;

  @override
  _CoinsListAllState createState() => _CoinsListAllState();
}

class _CoinsListAllState extends State<CoinsListAll> {
  ConstructorProvider _constrProvider;
  OrderBookProvider _obProvider;
  int _timer;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _obProvider ??= Provider.of<OrderBookProvider>(context);

    final List<ListAllItem> items = _getItems();

    if (items.isEmpty) {
      final int now = DateTime.now().millisecondsSinceEpoch;
      setState(() => _timer ??= now);
      if (now - _timer > 1000) {
        return EmptyListMessage();
      } else {
        return _buildProgress();
      }
    }

    setState(() => _timer = null);

    return Container(
      padding: EdgeInsets.only(left: 12),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, i) {
          return _buildCoinItem(items[i]);
        },
      ),
    );
  }

  Widget _buildProgress() {
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 150),
        child: Center(child: CircularProgressIndicator()));
  }

  Widget _buildCoinItem(ListAllItem item) {
    String keyName = widget.type == Market.SELL
        ? 'sell-${item.coin.abbr}'
        : 'buy-${item.coin.abbr}';
    return Opacity(
      opacity: item.coin.isActive ? 1 : 0.3,
      child: Card(
        margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
        child: ListTile(
          key: Key(keyName),
          visualDensity: VisualDensity.compact,
          onTap: () {
            widget.type == Market.SELL
                ? _constrProvider.sellCoin = item.coin.abbr
                : _constrProvider.buyCoin = item.coin.abbr;
          },
          minLeadingWidth: 16,
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          horizontalTitleGap: 8,
          leading: CircleAvatar(
            radius: 8,
            backgroundImage: AssetImage(getCoinIconPath(item.coin.abbr)),
          ),
          title: Text(
            item.coin.abbr,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          trailing: widget.type == Market.SELL
              ? AutoScrollText(
                  text: item.balance,
                  style: Theme.of(context).textTheme.caption,
                )
              : null,
        ),
      ),
    );
  }

  List<ListAllItem> _getItems() {
    final List<ListAllItem> available = [];
    final List<CoinBalance> active = coinsBloc.coinBalance;

    for (CoinBalance coinBalance in active) {
      if (coinBalance.coin.walletOnly) continue;
      if (coinBalance.coin.suspended) continue;

      final String term = widget.searchTerm.trim().toLowerCase();
      if (term.isNotEmpty) {
        final Coin coin = coinBalance.coin;
        bool matched = false;
        if (coin.abbr.toLowerCase().contains(term)) matched = true;
        if (coin.name.toLowerCase().contains(term)) matched = true;

        if (!matched) continue;
      }

      available.add(ListAllItem(coin: coinBalance.coin));
    }

    return available;
  }
}

class ListAllItem {
  ListAllItem({this.coin});

  String get balance {
    final Decimal coinBalance =
        coinsBloc.getBalanceByAbbr(coin.abbr)?.balance?.balance ?? deci(0);
    return cutTrailingZeros(formatPrice(coinBalance));
  }

  Coin coin;
}
