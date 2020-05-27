import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/utils/utils.dart';

class BuildNewsItem extends StatefulWidget {
  const BuildNewsItem(this.newsItem);

  final NewsItem newsItem;

  @override
  _BuildNewsItemState createState() => _BuildNewsItemState();
}

class _BuildNewsItemState extends State<BuildNewsItem> {
  final List<TapGestureRecognizer> _recognizers = [];
  final String _urlMatcher =
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
  final String _urlWrap = '%%';

  @override
  void dispose() {
    for (TapGestureRecognizer recognizer in _recognizers) {
      recognizer.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String _date =
        humanDate(DateTime.parse(widget.newsItem.date).millisecondsSinceEpoch);

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
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.newsItem.content == null || widget.newsItem.content.isEmpty) {
      return Container();
    }

    final String _urlWrapped = widget.newsItem.content.replaceAllMapped(
        RegExp(_urlMatcher), (match) => '$_urlWrap${match.group(0)}$_urlWrap');

    final List<String> _chunks = _urlWrapped.split(_urlWrap);

    final List<TextSpan> _spans = [];
    for (String _chunk in _chunks) {
      if (RegExp(_urlMatcher).hasMatch(_chunk)) {
        final TapGestureRecognizer _recognizer = TapGestureRecognizer()
          ..onTap = () => launchURL(_chunk);
        _recognizers.add(_recognizer);

        _spans.add(TextSpan(
          text: '$_chunk',
          style: TextStyle(color: Colors.blue, fontSize: 16),
          recognizer: _recognizer,
        ));
      } else {
        _spans.add(TextSpan(
          text: '$_chunk',
          style: const TextStyle(fontSize: 16),
        ));
      }
    }
    return RichText(
      text: TextSpan(children: _spans),
    );
  }
}
