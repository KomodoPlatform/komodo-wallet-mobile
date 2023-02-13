import 'package:flutter/material.dart';
import '../../../../../model/market.dart';
import '../../../../../widgets/auto_scroll_text.dart';
import 'package:rational/rational.dart';
import '../../../../../model/swap_constructor_provider.dart';
import '../../../../../utils/utils.dart';
import 'package:provider/provider.dart';

class BuildRateSimple extends StatefulWidget {
  @override
  _BuildRateSimpleState createState() => _BuildRateSimpleState();
}

class _BuildRateSimpleState extends State<BuildRateSimple> {
  ConstructorProvider? _constrProvider;
  bool _isInverse = false;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of(context);

    if (_constrProvider!.matchingOrder == null) {
      return SizedBox();
    }

    final TextStyle style = Theme.of(context)
        .textTheme
        .caption!
        .copyWith(color: Theme.of(context).textTheme.bodyText1!.color);

    final String? coin =
        _isInverse ? _constrProvider!.buyCoin : _constrProvider!.sellCoin;
    final String? otherCoin =
        _isInverse ? _constrProvider!.sellCoin : _constrProvider!.buyCoin;
    Rational? price = _isInverse
        ? _constrProvider!.matchingOrder!.price!.inverse
        : _constrProvider!.matchingOrder!.price;
    if (_constrProvider!.matchingOrder!.action == Market.BUY) {
      price = price!.inverse;
    }

    return InkWell(
      onTap: () => setState(() => _isInverse = !_isInverse),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('1 $coin = ', style: style),
            Flexible(
              child: AutoScrollText(
                text: cutTrailingZeros(formatPrice(price)),
                style: style,
              ),
            ),
            Text(' $otherCoin', style: style),
          ],
        ),
      ),
    );
  }
}
