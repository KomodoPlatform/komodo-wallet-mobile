import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/article.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';
import 'media_page.dart';

class MediaDetailPage extends StatefulWidget {
  const MediaDetailPage({this.article});

  final Article article;

  @override
  _MediaDetailPageState createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  @override
  Widget build(BuildContext context) {
    final TextStyle body2Light = Theme.of(context)
        .textTheme
        .body1
        .copyWith(color: Colors.black.withOpacity(0.7), fontSize: 14);
    final String splitText1 =
        widget.article.body.substring(0, widget.article.body.length ~/ 2);
    final String splitText2 =
        widget.article.body.substring(widget.article.body.length ~/ 2);

    return LockScreen(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).newsFeed.toUpperCase(),
            style: Theme.of(context).textTheme.subtitle,
          ),
          bottom: PreferredSize(
            preferredSize: const Size(0.0, 36.0),
            child: Container(
              height: 36,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    timeago.format(widget.article.creationDate),
                    style: body2Light,
                  ),
                  Expanded(
                    child: Text(
                      ' | ${AppLocalizations.of(context).mediaBy} ${widget.article.author}',
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
            Container(
              height: 250,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(0.0)),
                child: Image.network(
                  widget.article.media[0],
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
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
                splitText1,
                style: body2Light,
              ),
            ),
            Builder(builder: (BuildContext context) {
              if (widget.article.media.length > 1) {
                final List<Widget> medias = widget.article.media.map((String i) {
                    return Container(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(0.0)),
                        child: Image.network(
                          i,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    );
                  }).toList();
                medias.removeAt(0);
                return CarouselSlider(
                  autoPlay: true,
                  height: 250,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  items: medias,
                );
              } else {
                return Container();
              }
            }),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                splitText2,
                style: body2Light,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
