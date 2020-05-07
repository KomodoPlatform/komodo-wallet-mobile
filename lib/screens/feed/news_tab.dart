import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/media_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/article.dart';
import 'package:komodo_dex/screens/feed/media_detail_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share/share.dart';

class NewsTab extends StatefulWidget {
  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Article>>(
        stream: mediaBloc.outArticles,
        initialData: mediaBloc.articles,
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          if (snapshot.hasData) {
            final List<Article> articles = snapshot.data;

            if (articles.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.info,
                    color: Colors.grey,
                    size: 48,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    AppLocalizations.of(context).noArticles,
                    style: Theme.of(context).textTheme.title,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0)
                  return _buildHeader(articles[index]);
                else
                  return ArticleItem(
                    article: articles[index],
                  );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Center(
                child: Container(
              child: const Text('No news'),
            ));
          }
        });
  }

  Widget _buildHeader(Article article) {
    double _imageHeight = MediaQuery.of(context).size.height * 0.3;
    if (_imageHeight < 200) _imageHeight = 200;

    return InkWell(
      onTap: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => MediaDetailPage(
                    article: article,
                  )),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 20),
            alignment: Alignment.center,
            height: _imageHeight,
            child: Image.network(
              article.media[0],
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AutoSizeText(
              article.title,
              style: Theme.of(context).textTheme.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              minFontSize: Theme.of(context).textTheme.title.fontSize,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    timeago.format(article.creationDate),
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
                IconsArticle(
                  article: article,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 1,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.withOpacity(0.2),
            ),
          )
        ],
      ),
    );
  }
}

class ArticleItem extends StatefulWidget {
  const ArticleItem({this.article});

  final Article article;

  @override
  _ArticleItemState createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {
  final double _heightCard = 130.0;

  @override
  Widget build(BuildContext context) {
    final Article article = widget.article;

    return InkWell(
      onTap: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => MediaDetailPage(
                    article: article,
                  )),
        );
      },
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Row(
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: _heightCard,
                      child: Image.network(
                        article.media[0],
                        fit: BoxFit.cover,
                      )),
                  Expanded(
                    child: Container(
                      height: _heightCard,
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AutoSizeText(
                            article.title,
                            style: Theme.of(context).textTheme.subtitle,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            minFontSize:
                                Theme.of(context).textTheme.subtitle.fontSize,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: Text(
                                article.getTimeFormat(),
                                style: Theme.of(context).textTheme.body2,
                              )),
                              IconsArticle(article: article)
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 1,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class IconsArticle extends StatefulWidget {
  const IconsArticle({this.article});

  final Article article;

  @override
  _IconsArticleState createState() => _IconsArticleState();
}

class _IconsArticleState extends State<IconsArticle> {
  @override
  void dispose() {
    mainBloc.isUrlLaucherIsOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            onTap: () {
              mainBloc.isUrlLaucherIsOpen = true;

              Share.share(
                  '${AppLocalizations.of(context).articleFrom}:\n\n${widget.article.title}\nBy ${widget.article.author}\n${timeago.format(widget.article.creationDate)}\n\n${widget.article.body}');
            },
            child: Icon(Icons.share, color: Colors.grey, size: 30)),
      ],
    );
  }
}
