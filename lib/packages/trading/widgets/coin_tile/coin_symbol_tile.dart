import 'package:flutter/material.dart';

class CoinSymbolTile extends StatelessWidget {
  const CoinSymbolTile({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.imageUrl,
    this.children = const [],
    // this.onTap,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Widget> children;
  // final Function onTap;

  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(title),
      subtitle: Text(subtitle),
      leading: CircleAvatar(
        foregroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.transparent,
      ),
      children: children,
    );
  }
}
