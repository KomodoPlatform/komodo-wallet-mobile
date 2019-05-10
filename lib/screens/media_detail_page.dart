import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/article.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';
import 'media_page.dart';

class MediaDetailPage extends StatefulWidget {
  final Article article;

  MediaDetailPage({this.article});

  @override
  _MediaDetailPageState createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  @override
  Widget build(BuildContext context) {
    TextStyle body2Light = Theme.of(context)
        .textTheme
        .body1
        .copyWith(color: Colors.black.withOpacity(0.7), fontSize: 14);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).newsFeed.toUpperCase(),
          style: Theme.of(context).textTheme.subtitle,
        ),
        bottom: PreferredSize(
          preferredSize: new Size(0.0, 36.0),
          child: Container(
            height: 36,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                Text(
                  timeago.format(widget.article.creationDate),
                  style: body2Light,
                ),
                Expanded(
                  child: Text(
                    ' | By ${widget.article.author}',
                    style: body2Light,
                  ),
                ),
                IconsArticle(
                  article: widget.article,
                  savedArticle: widget.article.isSavedArticle,
                )
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          CarouselSlider(
            autoPlay: true,
            height: 250,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            items: widget.article.media.map((i) {
              return Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                  child: Image.network(
                    i,
                    fit: BoxFit.cover,
                    width: 1000.0,
                  ),
                ),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.article.title,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Theme.of(context).accentColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.article.body,
              style: body2Light,
            ),
          )
        ],
      ),
    );
  }
}
