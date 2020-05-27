import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/utils/utils.dart';

class BuildNewsItem extends StatelessWidget {
  const BuildNewsItem(this.newsItem);

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    final String _date =
        humanDate(DateTime.parse(newsItem.date).millisecondsSinceEpoch);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _date,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).accentColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            newsItem.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
