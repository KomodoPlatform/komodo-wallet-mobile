import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/utils.dart';

class NewsArticle {
  NewsArticle(
    this.source, {
    this.preferredLeadLength = 200,
  }) {
    _spanList = [TextSpan(text: source)];

    _parseMarkdown();
    _parseLinks();
    _collectStats();
    _createStructure();
  }

  String source;
  int preferredLeadLength;

  List<TextSpan> _spanList;
  List<TextSpan> _lead;
  List<TextSpan> _body;
  int _totalLength = 0;
  final List<TapGestureRecognizer> _recognizers = [];

  List<TextSpan> get lead => _lead;
  List<TextSpan> get body => _body;
  List<TextSpan> get full => _spanList;
  int get length => _totalLength;
  List<TapGestureRecognizer> get recognizers => _recognizers;

  void _createStructure() {
    int _symbolsFromStart = 0;
    bool _isLeadFilled = false;
    for (TextSpan span in full) {
      if (_isLeadFilled) {
        _body ??= [];
        _body.add(span);
        continue;
      }

      _lead ??= [];
      _symbolsFromStart += span.text.length;
      if (_symbolsFromStart < preferredLeadLength) {
        _lead.add(span);
      } else {
        String _leadSubstring;
        String _bodySubstring;

        int _prefferedCut = preferredLeadLength - _length(_lead);
        if (_prefferedCut < 0) _prefferedCut = 0;

        final int _closestEndOfSentence = _closest(
              string: span.text,
              symbol: '.',
              startFrom: _prefferedCut,
            ) ??
            _closest(
              string: span.text,
              symbol: '?',
              startFrom: _prefferedCut,
            ) ??
            _closest(
              string: span.text,
              symbol: '!',
              startFrom: _prefferedCut,
            );
        int _closestLineBreak = _closest(
          string: span.text,
          symbol: '\n',
          startFrom: _prefferedCut,
        );
        if (_closestLineBreak != null && _closestLineBreak > 0) {
          _closestLineBreak--;
        }
        final int _closestSpace = _closest(
          string: span.text,
          symbol: ' ',
          startFrom: _prefferedCut,
        );

        final int _cut = _closestLineBreak ??
            _closestEndOfSentence ??
            _closestSpace ??
            _prefferedCut;

        if (_totalLength - _length(_lead) - _cut < _totalLength / 4) {
          _lead ??= [];
          _lead.add(span);
          continue;
        }

        _isLeadFilled = true;

        if (span.text.length - _cut < _cut / 2) {
          _lead ??= [];
          _lead.add(span);
          continue;
        }

        _leadSubstring = span.text.substring(0, _cut);
        _bodySubstring = span.text.substring(_cut + 1);

        _lead ??= [];
        _lead.add(TextSpan(
          text: _leadSubstring,
          style: span.style,
          recognizer: span.recognizer,
        ));

        _body ??= [];
        _body.add(TextSpan(
          text: _bodySubstring,
          style: span.style,
          recognizer: span.recognizer,
        ));
      }
    }
  }

  void _collectStats() {
    _totalLength = _length(full);
  }

  int _length(List<TextSpan> input) {
    int _count = 0;
    for (TextSpan span in input) {
      _count += span.text.length;
    }
    return _count;
  }

  int _closest({String string, String symbol, int startFrom}) {
    int _position;
    int _offset = 0;

    while (true) {
      String _behind;
      String _ahead;
      try {
        _behind = string.substring(
            startFrom - _offset, startFrom - _offset + symbol.length);
      } catch (_) {}
      try {
        _ahead = string.substring(
            startFrom + _offset, startFrom + _offset + symbol.length);
      } catch (_) {}
      if (_ahead == null && _behind == null) break;

      if (_ahead == symbol) {
        _position = startFrom + _offset;
        break;
      }
      if (_behind == symbol) {
        _position = startFrom - _offset;
        break;
      }

      _offset++;
    }

    return _position;
  }

  void _parseLinks() {
    const String _urlMatcher =
        r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
    const String _urlWrap = '|~url~|';
    final List<TextSpan> _parsed = [];

    for (TextSpan _span in _spanList) {
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

    _spanList = _parsed;
  }

  void _parseMarkdown() {
    final List<TextSpan> _parsed = List.from(_spanList);

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

    _spanList = _parsed;
  }
}
