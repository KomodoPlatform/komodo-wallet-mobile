import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/media_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/article.dart';
import 'package:komodo_dex/utils/custom_tab_indicator.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'media_detail_page.dart';

class Media extends StatefulWidget {
  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> with SingleTickerProviderStateMixin {
  TabController _controllerTabs;
  @override
  void initState() {
    _controllerTabs = TabController(length: 2, vsync: this);
    _controllerTabs.addListener(_getIndex);
    mediaBloc.getArticles();
    mediaBloc.getArticlesSaved();
    super.initState();
  }

  @override
  void dispose() {
    _controllerTabs.dispose();
    super.dispose();
  }

  void _getIndex() {
    print(_controllerTabs.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Center(
            child: Text(
          AppLocalizations.of(context).newsFeed.toUpperCase(),
          style: Theme.of(context).textTheme.subtitle,
        )),
        bottom: PreferredSize(
          preferredSize:  const Size(200.0, 70.0),
          child: Container(
            width: 200.0,
            height: 70,
            padding: const EdgeInsets.only(bottom: 16, top: 16),
            child: Container(
              height: 46,
              decoration:  BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  border:  Border.all(color: Colors.grey, width: 1)),
              child: TabBar(
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                indicator: CustomTabIndicator(context: context),
                controller: _controllerTabs,
                tabs: <Widget>[
                  Tab(text: AppLocalizations.of(context).mediaBrowse),
                  Tab(text: AppLocalizations.of(context).mediaSaved)
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _controllerTabs,
        children: <Widget>[
          BrowseNews(),
          SavedNews(tabController: _controllerTabs)
        ],
      ),
    );
  }
}

class BrowseNews extends StatefulWidget {
  @override
  _BrowseNewsState createState() => _BrowseNewsState();
}

class _BrowseNewsState extends State<BrowseNews> {
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
                    savedArticle: false,
                  );
              },
            );
          
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          } else {
            return Center(child: Container(child: const Text('No news'),));
          }
        });
  }

  Widget _buildHeader(Article article) {
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
            height: MediaQuery.of(context).size.height * 0.3,
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
                  savedArticle: false,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ArticleItem extends StatefulWidget {
  const ArticleItem({this.article, this.savedArticle});

  final Article article;
  final bool savedArticle;


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
                              IconsArticle(
                                  article: article,
                                  savedArticle: widget.savedArticle)
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
  const IconsArticle({this.article, this.savedArticle});

  final Article article;
  final bool savedArticle;


  @override
  _IconsArticleState createState() => _IconsArticleState();
}

class _IconsArticleState extends State<IconsArticle> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: Icon(
            widget.article.isSavedArticle
                ? Icons.bookmark
                : Icons.bookmark_border,
            size: 30,
            color: widget.article.isSavedArticle
                ? Theme.of(context).accentColor
                : Colors.grey,
          ),
          onTap: () {
            print(widget.article.isSavedArticle);
            if (widget.article.isSavedArticle) {
              setState(() {
                widget.article.isSavedArticle = false;
              });
              mediaBloc.deleteArticle(widget.article);
            } else {
              setState(() {
                widget.article.isSavedArticle = true;
              });
              mediaBloc.addArticle(widget.article);
            }
          },
        ),
        const SizedBox(
          width: 8,
        ),
        InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            onTap: () {
              Share.share(
                  '${AppLocalizations.of(context).articleFrom}:\n\n${widget.article.title}\nBy ${widget.article.author}\n${timeago.format(widget.article.creationDate)}\n\n${widget.article.body}');
            },
            child: Icon(Icons.share, color: Colors.grey, size: 30)),
      ],
    );
  }
}

class SavedNews extends StatelessWidget {
  const SavedNews({this.tabController});

  final TabController tabController;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Article>>(
        stream: mediaBloc.outArticlesSaved,
        initialData: mediaBloc.articlesSaved,
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          if (snapshot.hasData) {
            final List<Article> articles = snapshot.data;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (BuildContext context, int index) {
                return ArticleItem(
                    article: articles[index], savedArticle: true);
              },
            );
          } else if (snapshot.data.isEmpty) {//paradox condition cleaned up
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset('assets/icon_not_saved.svg'),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  AppLocalizations.of(context).mediaNotSavedDescription,
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 32,
                ),
                RaisedButton(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  color: Theme.of(context).accentColor,
                  disabledColor: Theme.of(context).disabledColor,
                  child: Text(
                    AppLocalizations.of(context).mediaBrowseFeed,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () async {
                    tabController.animateTo(0);
                  },
                )
              ],
            );
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        });
  }
}
