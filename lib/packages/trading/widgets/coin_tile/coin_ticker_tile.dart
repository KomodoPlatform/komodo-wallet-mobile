import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/trading/widgets/coin_select/ticker_badge.dart';

class CoinTickerTile extends StatelessWidget {
  const CoinTickerTile({
    @required this.title,
    @required this.subtitle,
    @required this.imageUrl,
    this.onTap,
    this.chainImageUrl,
    Key key,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String imageUrl;
  final String chainImageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 4.0,
      title: Text(title),
      dense: true,
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
      leading: TickerBadge(
        coinImageProvider: imageUrl == null ? null : NetworkImage(imageUrl),
        chainImageProvider:
            chainImageUrl == null ? null : NetworkImage(chainImageUrl),
      ),
      onTap: onTap,
    );
  }
}
