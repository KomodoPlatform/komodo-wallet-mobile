import 'package:flutter/material.dart';

class NewsArticle {
  NewsArticle(
    this.source, {
    this.preferredLeadLength = 200,
  }) {
    _collectStats();
    _createStructure();
  }

  List<TextSpan> source;
  int preferredLeadLength;

  List<TextSpan> _lead;
  List<TextSpan> _body;
  int _totalLength = 0;

  List<TextSpan> get lead => _lead;
  List<TextSpan> get body => _body;
  List<TextSpan> get full => source;
  int get length => _totalLength;

  void _createStructure() {
    int _symbolsFromStart = 0;
    bool _isLeadFilled = false;
    for (TextSpan span in source) {
      if (_isLeadFilled) {
        _body ??= [];
        _body.add(span);
        continue;
      }

      _lead ??= [];
      _symbolsFromStart += span.text.length;
      if (_symbolsFromStart > preferredLeadLength) {
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
        final int _closestLineBreak = _closest(
          string: span.text,
          symbol: '\n',
          startFrom: _prefferedCut,
        );
        final int _closestSpace = _closest(
          string: span.text,
          symbol: ' ',
          startFrom: _prefferedCut,
        );

        final int _cut = _closestLineBreak ??
            _closestEndOfSentence ??
            _closestSpace ??
            _prefferedCut;

        if (_totalLength - _length(_lead) - _cut < _totalLength / 5) {
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
      } else {
        _lead.add(span);
      }
    }
  }

  void _collectStats() {
    _totalLength = _length(source);
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
        _behind = string.substring(startFrom - _offset, startFrom - _offset + symbol.length);
      } catch (_) {}
      try {
        _ahead = string.substring(startFrom + _offset, startFrom + _offset + symbol.length); 
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
}
