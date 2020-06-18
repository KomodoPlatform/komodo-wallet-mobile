import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider() {
    _updateData();
    ticker = Timer.periodic(const Duration(minutes: 5), (_) {
      _updateData();
    });
  }

  Timer ticker;
  List<NewsItem> _news;

  @override
  void dispose() {
    super.dispose();
    ticker?.cancel();
  }

  List<NewsItem> getNews() => _news;
  Future<String> updateNews() => _updateNews();

  /// If news was successfully fetched and proceed,
  /// updates _news, local cache, and returns 'ok'.
  /// If failed - returns error message string
  Future<String> _updateNews() async {
    http.Response response;
    try {
      response = await http.get(
          'http://95.217.26.153/messages'); // TODO(yurii): change to domain name after DNS being updated
    } catch (e) {
      Log('feed_provider:44', '_updateNews] $e');
    }
    if (response?.statusCode != 200) {
      return 'Unable to get news'; // TODO(yurii): localization
    }

    List<NewsItem> news;
    try {
      news = _newsFromJson(response.body);
    } catch (e) {
      Log('feed_provider:52', '_updateNews] $e');
    }
    if (news == null) {
      return 'Unable to proceed news'; // TODO(yurii): localization
    }

    _news = news;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedNews', response.body);

    return 'ok';
  }

  Future<void> _updateData() async {
    if (_news == null || _news.isEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String cachedNews = prefs.getString('cachedNews');
      if (cachedNews != null) {
        _news = _newsFromJson(cachedNews);
        notifyListeners();
      }
    }

    if (await _updateNews() == 'ok') notifyListeners();
  }

  List<NewsItem> _newsFromJson(String body) {
    final List<dynamic> json = jsonDecode(body);
    List<NewsItem> news;
    for (dynamic item in json) {
      final String content = item['content'];
      if (content == null || content.isEmpty) continue;
      news ??= [];
      news.add(NewsItem(
        date: item['date'],
        content: content,
      ));
    }
    return news;
  }
}

class NewsItem {
  NewsItem({this.date, this.content, this.source});

  String date;
  String content;
  NewsSource source;
}

class NewsSource {
  NewsSource({this.name, this.url, this.pic});

  String name;
  String url;
  String pic;
}
