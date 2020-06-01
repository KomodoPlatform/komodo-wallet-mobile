import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/news/news_article.dart';
import 'package:komodo_dex/utils/utils.dart';

class BuildNewsItem extends StatefulWidget {
  const BuildNewsItem(this.newsItem);

  final NewsItem newsItem;

  @override
  _BuildNewsItemState createState() => _BuildNewsItemState();
}

class _BuildNewsItemState extends State<BuildNewsItem> {
  List<TapGestureRecognizer> _recognizers;
  bool _collapsed = true;

  @override
  void dispose() {
    for (TapGestureRecognizer recognizer in _recognizers) {
      recognizer.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _date;
    try {
      _date = humanDate(
          DateTime.parse(widget.newsItem.date).millisecondsSinceEpoch);
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_date != null)
            Text(
              _date,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).accentColor,
              ),
            ),
          const SizedBox(height: 10),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.newsItem.content == null || widget.newsItem.content.isEmpty) {
      return Container();
    }

    final NewsArticle _article = NewsArticle(widget.newsItem.content);
    _recognizers = _article.recognizers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16),
            children: _article.lead,
          ),
        ),
        if (_article.body != null && _collapsed)
          GestureDetector(
              onTap: () {
                setState(() {
                  _collapsed = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.only(top: 12),
                child: Text('Read more...', // TODO(yurii): localization
                    style: TextStyle(fontSize: 16, color: Colors.blue)),
              )),
        if (_article.body != null && !_collapsed)
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16),
              children: _article.body,
            ),
          ),
      ],
    );
  }
}
