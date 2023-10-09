import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';

/// Vertical bar-graph widget that shows the proportion of the value of each
/// asset in the user's wallet according to the fiat USD value.
///
/// The width of each asset animates when the user's coin balances change or
/// when the conversion rate of the coins changes.
class AnimatedAssetProportionsBarGraph extends StatefulWidget {
  const AnimatedAssetProportionsBarGraph({Key key}) : super(key: key);

  @override
  State<AnimatedAssetProportionsBarGraph> createState() =>
      _AnimatedAssetProportionsBarGraphState();
}

class _AnimatedAssetProportionsBarGraphState
    extends State<AnimatedAssetProportionsBarGraph> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinBalance>>(
      key: Key('animated_asset_proportions_bar_graph_streamer'),
      initialData: coinsBloc.coinBalance,
      stream: coinsBloc.outCoins,
      builder:
          (BuildContext context, AsyncSnapshot<List<CoinBalance>> snapshot) {
        final bool _isVisible = snapshot.data != null;

        final balance = snapshot.data
            .fold(0, (sum, coinBalance) => sum + coinBalance.balanceUSD);

        final barProportions =
            (snapshot.data ?? []).where((c) => c.balanceUSD > 0).map((c) {
          final widthFraction = ((c.balanceUSD * 100) / balance) / 100;
          return MapEntry(c.coin, widthFraction);
        });

        return LayoutBuilder(
          key: Key('animated_asset_proportions_bar_graph_layout_builder'),
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;

            final Iterable<Widget> bars = barProportions.map((e) {
              return AnimatedContainer(
                key: Key(e.key.abbr),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                color: Color(int.parse(e.key.colorCoin)),
                width: totalWidth * e.value,
              );
            });

            return ClipRect(
              key: Key('animated_asset_proportions_bar_graph_clip_rect'),
              child: AnimatedOpacity(
                key: Key(
                  'animated_asset_proportions_bar_graph_animated_opacity',
                ),
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: totalWidth,
                  height: 16,
                  child: Row(
                    children: bars.toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
