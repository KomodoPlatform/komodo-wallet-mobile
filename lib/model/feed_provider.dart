import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../app_config/app_config.dart';
import '../localizations.dart';
import '../services/notif_service.dart';
import '../utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider() {
    _updateData();
    _ticker = Timer.periodic(const Duration(minutes: 5), (_) {
      _updateData();
    });
  }

  Timer? _ticker;
  List<NewsItem>? _news;
  bool _isNewsFetching = false;

  // TODO: Refactor [_hasNewItems] to be a simple getter of [_unreadCount].
  bool _hasNewItems = false;
  AppLocalizations localizations = AppLocalizations();

  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  @override
  void dispose() {
    super.dispose();
    _ticker?.cancel();
  }

  bool get isNewsFetching => _isNewsFetching;
  bool get hasNewItems => _hasNewItems;
  set hasNewItems(bool value) {
    _hasNewItems = value;
    notifyListeners();
  }

  List<NewsItem>? getNews() => _news;

  Future<String> updateNews() => _updateNews();

  /// If news was successfully fetched and proceed,
  /// updates _news, local cache, and returns 'ok'.
  /// If failed - returns error message string
  Future<String> _updateNews() async {
    _isNewsFetching = true;
    notifyListeners();
    http.Response? response;

    try {
      response = await http.get(Uri.parse(appConfig.feedProviderSourceUrl));
    } catch (e) {
      Log('feed_provider:44', '_updateNews] $e');
    }
    _isNewsFetching = false;
    notifyListeners();
    if (response?.statusCode != 200) {
      return localizations.feedUnableToUpdate;
    }

    List<NewsItem>? news;
    try {
      news = _newsFromJson(response!.body);
    } catch (e) {
      Log('feed_provider:52', '_updateNews] $e');
    }
    if (news == null) {
      return localizations.feedUnableToProceed;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedNews = prefs.getString('cachedNews');
    if (cachedNews != null &&
        _newsFromJson(cachedNews)![0].date == news[0].date) {
      return localizations.feedUpToDate;
    }

    prefs.setString('cachedNews', response!.body);
    _hasNewItems = true;
    _unreadCount = news.length;
    _news = news;

    notifService.show(
      NotifObj(
        title: localizations.feedNotifTitle(appConfig.appCompanyShort),
        text: _news![0].content,
        uid: 'feed_${_news![0].date}',
      ),
    );

    notifyListeners();
    return 'ok';
  }

  Future<void> _updateData() async {
    if (_news == null || _news!.isEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedNews = prefs.getString('cachedNews');
      if (cachedNews != null) {
        _news = _newsFromJson(cachedNews);
        notifyListeners();
      }
    }

    if (await _updateNews() == 'ok') {
      notifyListeners();
    } else if (_news == null) {
      _news = []; // hide progress indicator and show empty feed message
      _unreadCount = 0;
      notifyListeners();
    }
  }

  List<NewsItem>? _newsFromJson(String body) {
    final List<dynamic> json = jsonDecode(body);
    List<NewsItem>? news;
    for (dynamic item in json) {
      final String? content = item['content'];
      if (content == null || content.isEmpty) continue;
      news ??= [];
      news.add(
        NewsItem(
          date: item['date'],
          content: content,
        ),
      );
    }
    return news;
  }
}

class NewsItem {
  NewsItem({this.date, this.content, this.source});

  String? date;
  String? content;
  NewsSource? source;
}

class NewsSource {
  NewsSource({this.name, this.url, this.pic});

  String? name;
  String? url;
  String? pic;
}
