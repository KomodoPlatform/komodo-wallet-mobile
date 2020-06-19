import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/news/build_news_item.dart';
import 'package:provider/provider.dart';

class NewsTab extends StatefulWidget {
  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  FeedProvider _feedProvider;
  List<NewsItem> _news;

  @override
  Widget build(BuildContext context) {
    _feedProvider = Provider.of<FeedProvider>(context);
    _news = _feedProvider.getNews();

    if (_news == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_news.isEmpty) {
      return const Center(
          child: Text(
        'Nothing here', // TODO(yurii): localization
        style: TextStyle(fontSize: 13),
      ));
    }

    Widget _buildUpdateIndicator() {
      return _feedProvider.isNewsFetching
          ? const SizedBox(
              height: 1,
              child: LinearProgressIndicator(),
            )
          : Container(height: 1);
    }

    return Container(
      child: Column(
        children: <Widget>[
          _buildUpdateIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final String updateResponse = await _feedProvider.updateNews();
                String message;
                if (updateResponse == 'ok') {
                  message = 'News feed updated'; // TODO(yurii): localization
                } else {
                  message = updateResponse;
                }

                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    message,
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                  backgroundColor: Theme.of(context).backgroundColor,
                  duration: const Duration(seconds: 1),
                  action: SnackBarAction(
                    textColor: Theme.of(context).accentColor,
                    label: 'Dismiss', // TODO(yurii): localization
                    onPressed: () {
                      Scaffold.of(context).hideCurrentSnackBar();
                    },
                  ),
                ));
              },
              child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: _news.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Column(
                      children: <Widget>[
                        BuildNewsItem(_news[i]),
                        if (i + 1 < _news.length)
                          Divider(
                            endIndent: 12,
                            indent: 12,
                            height: 1,
                            color: Theme.of(context).disabledColor,
                          ),
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
