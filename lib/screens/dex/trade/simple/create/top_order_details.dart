import 'package:flutter/material.dart';
import 'package:komodo_dex/model/app_config.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:rational/rational.dart';
import 'package:komodo_dex/model/best_order.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:provider/provider.dart';

class TopOrderDetails extends StatefulWidget {
  @override
  _TopOrderDetailsState createState() => _TopOrderDetailsState();
}

class _TopOrderDetailsState extends State<TopOrderDetails> {
  ConstructorProvider _constrProvider;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    return Column(
      children: [
        _buildHeader(),
        if (_showDetails) _buildDetails(),
      ],
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 2, 0, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Order selected:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(width: 4),
            _buildOrderPrice(),
            Icon(
              _showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 16,
              color: Theme.of(context).textTheme.bodyText1.color,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrderPrice() {
    final BestOrder order = _constrProvider.matchingOrder;
    final Rational price =
        order.action == Market.SELL ? order.price : order.price.inverse;

    return Row(
      children: [
        Text(
          cutTrailingZeros(formatPrice(price)),
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Theme.of(context).textTheme.bodyText2.color,
              ),
        ),
        SizedBox(width: 2),
        Text(
          '${order.coin}/${order.otherCoin}',
          style: Theme.of(context).textTheme.bodyText1,
        )
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        _buildRate(),
        SizedBox(height: 4),
        _buildVolume(),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildVolume() {
    final BestOrder order = _constrProvider.matchingOrder;
    final Rational price =
        order.action == Market.SELL ? order.price : order.price.inverse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
          color: Theme.of(context).highlightColor.withAlpha(25),
          child: Text(
            'Volume:',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
          child: Text(
            'Min volume: '
            '${cutTrailingZeros((order.minVolume / price).toStringAsFixed(appConfig.tradeFormPrecision))} '
            '${order.otherCoin} / '
            '${cutTrailingZeros(order.minVolume.toStringAsFixed(appConfig.tradeFormPrecision))} '
            '${order.coin}',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
          child: Text(
            'Max volume: '
            '${cutTrailingZeros((order.maxVolume / price).toStringAsFixed(appConfig.tradeFormPrecision))} '
            '${order.otherCoin} / '
            '${cutTrailingZeros(order.maxVolume.toStringAsFixed(appConfig.tradeFormPrecision))} '
            '${order.coin}',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }

  Widget _buildRate() {
    final BestOrder order = _constrProvider.matchingOrder;
    final Rational price =
        order.action == Market.SELL ? order.price : order.price.inverse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
          color: Theme.of(context).highlightColor.withAlpha(25),
          child: Text(
            'Exchange rate:',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
          child: Text(
            '1 ${order.otherCoin} = '
            '${price.toStringAsFixed(appConfig.tradeFormPrecision)} '
            '${order.coin}',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
          child: Text(
            '1 ${order.coin} = '
            '${price.inverse.toStringAsFixed(appConfig.tradeFormPrecision)} '
            '${order.otherCoin}',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ],
    );
  }
}
