import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider() {
    _updateData();
    ticker = Timer.periodic(const Duration(minutes: 5), (_) {
      _updateData();
    });
  }

  Timer ticker;
  List<Dev> _devOps;
  List<Issue> _issues;
  List<NewsItem> _news;

  @override
  void dispose() {
    super.dispose();
    ticker?.cancel();
  }

  List<Dev> getDevOps() => _devOps;
  List<Issue> getIssues() => _issues;
  Dev getDev(String id) {
    if (_devOps == null) return null;
    return _devOps.firstWhere((Dev dev) => dev.id == id);
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

  List<DevStatus> sortTimeLine(List<DevStatus> unsorted) {
    if (unsorted == null) return null;
    if (unsorted.isEmpty) return [];

    final List<DevStatus> _sorted = List.from(unsorted);
    _sorted.sort((a, b) {
      if (a.startTime > b.startTime) return 1;
      if (a.startTime < b.startTime) return -1;
      return 0;
    });

    return _sorted;
  }
}

class Dev {
  Dev({
    @required this.id,
    this.name,
    this.image,
    this.activity,
  });

  String id;
  String name;
  String image;
  List<DevStatus> activity;

  List<DevStatus> get sortedHistory => _getSortedHistory();
  DevStatus get latestStatus => _getLatestStatus();
  OnlineStatus get onlineStatus => _getOnlineStatus();
  String get currentStatusMessage => _getCurrentStatusMessage();

  List<DevStatus> _getSortedHistory() {
    if (activity == null) return null;

    final List<DevStatus> _sorted = List.from(activity);
    if (_sorted.isEmpty) return _sorted;

    _sorted.sort((a, b) {
      if (a.startTime < b.startTime) return 1;
      if (a.startTime > b.startTime) return -1;
      return 0;
    });

    return _sorted;
  }

  OnlineStatus _getOnlineStatus() {
    if (latestStatus == null) return OnlineStatus.unknown;

    switch (latestStatus.endTime) {
      case null:
        {
          return OnlineStatus.active;
        }
      default:
        {
          return OnlineStatus.inactive;
        }
    }
  }

  String _getCurrentStatusMessage() {
    if (latestStatus == null) return '';

    switch (latestStatus.endTime) {
      case null:
        {
          return latestStatus.message ??
              'Active now'; // TODO(yurii): localization
        }
      default:
        {
          return 'Last active: ${humanDate(latestStatus.endTime)}'; // TODO(yurii): localization
        }
    }
  }

  DevStatus _getLatestStatus() {
    if (sortedHistory == null || sortedHistory.isEmpty) return null;
    return sortedHistory[0];
  }
}

class DevStatus {
  DevStatus({
    @required this.id,
    this.devId,
    this.message,
    this.issue,
    this.startTime,
    this.endTime,
  });

  String id;
  String devId;
  String message;
  Issue issue;
  int startTime;
  int endTime;
}

class Issue {
  Issue({
    @required this.id,
    this.title,
    this.url,
    this.devs,
  });

  String id;
  String title;
  String url;
  List<String> devs;
}

enum OnlineStatus {
  active,
  inactive,
  unknown,
}

class NewsItem {
  NewsItem({this.date, this.content});

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

List<Dev> devOpsListPlaceholder = [
  Dev(
    id: '0',
    name: 'ArtemGr',
    image: 'https://avatars2.githubusercontent.com/u/41847?s=460&v=4',
    activity: [],
  ),
  Dev(
    id: '1',
    name: 'tonymorony',
    //avatar: 'https://avatars0.githubusercontent.com/u/24797699?s=460&v=4',
  ),
  Dev(
    id: '2',
    name: 'MateusRodCosta',
    image: 'https://avatars1.githubusercontent.com/u/24463334?s=460&v=4',
  ),
  Dev(
      id: '3',
      name: 'yurii',
      image: 'https://avatars3.githubusercontent.com/u/29194552?s=150&v=4',
      activity: [
        DevStatus(
          id: '0',
          message: 'git',
          startTime: 1588922092000,
          endTime: 1588923652000,
        ),
        DevStatus(
            id: '1',
            message: '#757 orders duplicates',
            startTime: 1588923772000,
            endTime: 1588927072000,
            issue: Issue(
              id: '757',
              title: 'Orderbook page creating orders duplicates',
              url: 'https://github.com/ca333/komodoDEX/issues/757',
            )),
        DevStatus(
            id: '2',
            message: 'news, design and layout, \'DevOps\' tab 0',
            startTime: 1588927072000,
            issue: Issue(
              id: '701',
              title: 'rewamp the news section',
              url: 'https://github.com/ca333/komodoDEX/issues/701',
            )),
        DevStatus(
          id: '3',
          message: 'git',
          startTime: 1589009514000,
          endTime: 1589020314000,
        ),
        DevStatus(
            id: '4',
            message: '#757 orders duplicates',
            startTime: 1589020314000,
            endTime: 1589022774000,
            issue: Issue(
              id: '757',
              title: 'Orderbook page creating orders duplicates',
              url: 'https://github.com/ca333/komodoDEX/issues/757',
            )),
        DevStatus(
            id: '5',
            message: 'news, design and layout, \'DevOps\' tab 1',
            startTime: 1589022774000,
            issue: Issue(
              id: '701',
              title: 'rewamp the news section',
              url: 'https://github.com/ca333/komodoDEX/issues/701',
            )),
        DevStatus(
          id: '6',
          message: 'git',
          startTime: 1589109174000,
          endTime: 1589112774000,
        ),
        DevStatus(
            id: '7',
            message: '#757 orders duplicates',
            startTime: 1589112774000,
            endTime: 1589119974000,
            issue: Issue(
              id: '757',
              title: 'Orderbook page creating orders duplicates',
              url: 'https://github.com/ca333/komodoDEX/issues/757',
            )),
        DevStatus(
            id: '8',
            message: 'news, design and layout, \'DevOps\' tab 2',
            startTime: 1589551974000,
            issue: Issue(
              id: '701',
              title: 'rewamp the news section',
              url: 'https://github.com/ca333/komodoDEX/issues/701',
            )),
      ]),
];

List<Issue> issuesListPlaceholder = [
  Issue(
    id: '757',
    title: 'Orderbook page creating orders duplicates',
    url: 'https://github.com/ca333/komodoDEX/issues/757',
    devs: ['0', '3'],
  ),
  Issue(
    id: '701',
    title: 'rewamp the news section',
    url: 'https://github.com/ca333/komodoDEX/issues/701',
    devs: ['1', '2', '3'],
  ),
];

String newsPlaceholder =
    r'''[{"content":"@everyone \n\nKomodo will be on Turkish television!\n\nhttps://twitter.com/KomodoPlatform/status/1271813884098289671?s=20","date":"2020-06-18 07:51:09.541000"},{"content":"@everyone \n\nWe have published another article from our Blockchain Fundamentals series. \ud83d\udcda\n\nBlockchain Programming Languages: An Introductory Guide\n\nIf you\u2019re a developer looking to learn the right languages to begin your blockchain career, then this post is for you. In this article, we cover the most in-demand blockchain programming languages. We\u2019ll look at how each language is used in the context of blockchain programming, along with examples from major projects in the blockchain space. The three categories featured are protocol-level development, smart contract development, and software development kits (SDKs).\n\nRead more here.\nhttps://komodoplatform.com/blockchain-programming-languages/","date":"2020-06-18 07:18:48.906000"}]''';
