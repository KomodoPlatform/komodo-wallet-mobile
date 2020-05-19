import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/utils.dart';

class FeedProvider extends ChangeNotifier {
  List<Dev> getDevOps() => devOpsListPlaceholder;
  List<Issue> getIssues() => issuesListPlaceholder;
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
    this.message,
    this.issue,
    this.startTime,
    this.endTime,
  });

  String id;
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
  });

  String id;
  String title;
  String url;
}

enum OnlineStatus {
  active,
  inactive,
  unknown,
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
            message: 'news, design and layout, \'DevOps\' tab',
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
            message: 'news, design and layout, \'DevOps\' tab',
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
            message: 'news, design and layout, \'DevOps\' tab',
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
  ),
  Issue(
    id: '701',
    title: 'rewamp the news section',
    url: 'https://github.com/ca333/komodoDEX/issues/701',
  ),
];
