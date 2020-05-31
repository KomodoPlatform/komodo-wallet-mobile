import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/news/structured_article.dart';
import 'package:komodo_dex/utils/utils.dart';

class BuildNewsItem extends StatefulWidget {
  const BuildNewsItem(this.newsItem);

  final NewsItem newsItem;

  @override
  _BuildNewsItemState createState() => _BuildNewsItemState();
}

class _BuildNewsItemState extends State<BuildNewsItem> {
  final List<TapGestureRecognizer> _recognizers = [];
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

    List<TextSpan> _spanList = [TextSpan(text: widget.newsItem.content)];

    _spanList = _parseMarkdown(_spanList);
    _spanList = _parseLinks(_spanList);
    final StructuredArticle _article = StructuredArticle(_spanList);

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
              child: Row(
                children: <Widget>[
                  Text('More ',
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                  Icon(Icons.arrow_drop_down, size: 16, color: Colors.blue)
                ],
              )), // TODO(yurii): localization
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

  List<TextSpan> _parseLinks(List<TextSpan> input) {
    const String _urlMatcher =
        r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
    const String _urlWrap = '|~url~|';
    final List<TextSpan> _parsed = [];

    for (TextSpan _span in input) {
      final String _urlWrapped = _span.text.replaceAllMapped(
        RegExp(_urlMatcher),
        (match) => '$_urlWrap${match.group(0)}$_urlWrap',
      );
      final List<String> _chunks = _urlWrapped.split(_urlWrap);

      for (String _chunk in _chunks) {
        if (RegExp(_urlMatcher).hasMatch(_chunk)) {
          _recognizers
              .add(TapGestureRecognizer()..onTap = () => launchURL(_chunk));

          _parsed.add(TextSpan(
            text: '$_chunk',
            style: _span.style == null
                ? TextStyle(color: Colors.blue)
                : _span.style.copyWith(color: Colors.blue),
            recognizer: _recognizers.last,
          ));
        } else {
          _parsed.add(TextSpan(
            text: '$_chunk',
            style: _span.style,
          ));
        }
      }
    }

    return _parsed;
  }

  List<TextSpan> _parseMarkdown(List<TextSpan> input) {
    final List<TextSpan> _parsed = List.from(input);

    const Map<String, TextStyle> _styles = {
      '__': TextStyle(decoration: TextDecoration.underline),
      '_': TextStyle(fontStyle: FontStyle.italic),
      '~~': TextStyle(decoration: TextDecoration.lineThrough),
      '***': TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
      '**': TextStyle(fontWeight: FontWeight.bold),
      '*': TextStyle(fontStyle: FontStyle.italic),
    };

    _styles.forEach((String marker, _) {
      final List<TextSpan> _input = List.from(_parsed);
      _parsed.clear();

      final String _matcher =
          '(?<!http.*)${RegExp.escape(marker)}.*?${RegExp.escape(marker)}';
      const String _wrap = '|~mrk~|';

      for (TextSpan _span in _input) {
        final String _wrapped = _span.text.replaceAllMapped(
          RegExp(_matcher),
          (match) => '$_wrap${match.group(0)}$_wrap',
        );
        final List<String> _chunks = _wrapped.split(_wrap);

        for (String _chunk in _chunks) {
          if (_chunk.isEmpty) continue;

          if (RegExp(_matcher).hasMatch(_chunk)) {
            _parsed.add(TextSpan(
              text: '${_chunk.replaceAll(marker, '')}',
              style: _span.style == null
                  ? _styles[marker]
                  : _span.style.merge(_styles[marker]),
              recognizer: _span.recognizer,
            ));
          } else {
            _parsed.add(TextSpan(
              text: '$_chunk',
              style: _span.style,
              recognizer: _span.recognizer,
            ));
          }
        }
      }
    });

    return _parsed;
  }
}
