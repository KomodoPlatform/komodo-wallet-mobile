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

class _BuildNewsItemState extends State<BuildNewsItem>
    with SingleTickerProviderStateMixin {
  List<TapGestureRecognizer> _recognizers;
  bool _collapsed = true;
  AnimationController expandController;
  Animation<double> expandAnimation;

  @override
  void initState() {
    super.initState();

    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      animationBehavior: AnimationBehavior.preserve,
    );
    expandAnimation = CurvedAnimation(
      parent: expandController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    for (TapGestureRecognizer recognizer in _recognizers) {
      recognizer.dispose();
    }

    expandController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
      color: Theme.of(context).primaryColor,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            Divider(
              color: Colors.white,
              height: 40,
            ),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final NewsSource _source = widget.newsItem.source ??
        NewsSource(
          name: 'Komodo #official-news',
          url:
              'https://discord.com/channels/412898016371015680/412915799251222539',
          pic:
              'https://cdn.discordapp.com/icons/412898016371015680/a_157cb08c4198ad53b9e9b7168c930571.png',
        );

    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 18,
          backgroundImage:
              _source.pic != null ? NetworkImage(_source.pic) : null,
          backgroundColor: Theme.of(context).highlightColor,
          child: _source.pic == null
              ? Icon(
                  Icons.comment,
                  size: 20,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap:
                    _source.url == null ? null : () => launchURL(_source.url),
                child: Text(
                  _source.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              _buildDate(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDate() {
    String _date;
    try {
      _date = humanDate(
          DateTime.parse(widget.newsItem.date).millisecondsSinceEpoch);
    } catch (_) {}

    return _date == null
        ? Container(width: 0)
        : Text(
            _date,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.caption.color,
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
                  expandController.forward();
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 12, bottom: 20, right: 12),
                child: Text('Read more...', // TODO(yurii): localization
                    style: TextStyle(fontSize: 16, color: Colors.blue)),
              )),
        if (_article.body != null && !_collapsed)
          SizeTransition(
            axisAlignment: -1,
            sizeFactor: expandAnimation,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16),
                children: _article.body,
              ),
            ),
          ),
        if (_article.body == null || !_collapsed) const SizedBox(height: 20),
      ],
    );
  }
}
