import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/localizations.dart';
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
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            Divider(height: 40),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final NewsSource _source =
        widget.newsItem.source ?? appConfig.defaultNewsSource;

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
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: Colors.blue,
                      ),
                ),
              ),
              SizedBox(height: 4),
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

    return _date == null ? Container(width: 0) : Text(_date);
  }

  Widget _buildContent() {
    if (widget.newsItem.content == null || widget.newsItem.content.isEmpty) {
      return SizedBox();
    }
    final NewsArticle _article = NewsArticle(widget.newsItem.content);
    _recognizers = _article.recognizers;

    return Column(
      children: <Widget>[
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText2,
            children: _article.lead,
          ),
        ),
        if (_article.body != null && _collapsed) ...[
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _collapsed = false;
                  expandController.forward();
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
                child: Text(AppLocalizations.of(context).feedReadMore,
                    style: TextStyle(fontSize: 16, color: Colors.blue)),
              ),
            ),
          ),
        ],
        if (_article.body != null && !_collapsed)
          SizeTransition(
            axisAlignment: -1,
            sizeFactor: expandAnimation,
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText2,
                children: _article.body,
              ),
            ),
          ),
        if (_article.body == null || !_collapsed) const SizedBox(height: 20),
      ],
    );
  }
}
