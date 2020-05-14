import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_item.dart';

class DevOpsTab extends StatefulWidget {
  @override
  _DevOpsTabState createState() => _DevOpsTabState();
}

class _DevOpsTabState extends State<DevOpsTab> {
  String _selectedDevId;

  @override
  Widget build(BuildContext context) {
    final List<Dev> _devOps = _getDevOps();
    return Container(
      child: ListView.builder(
          itemCount: _devOps.length,
          itemBuilder: (BuildContext context, int i) {
            return BuildDevItem(
              _devOps[i],
              selected: _devOps[i].id == _selectedDevId,
              onToggle: (bool isSelected) {
                setState(() {
                  _selectedDevId = isSelected ? _devOps[i].id : null;
                });
              },
            );
          }),
    );
  }

  List<Dev> _getDevOps() {
    return [
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
                endTime: 1588937072000,
                issue: Issue(
                  id: '701',
                  title: 'rewamp the news section rewamp',
                  url: 'https://github.com/ca333/komodoDEX/issues/701',
                )),
          ]),
    ];
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
